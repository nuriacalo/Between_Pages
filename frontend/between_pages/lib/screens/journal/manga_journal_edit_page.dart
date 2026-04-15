import 'package:between_pages/models/journal/manga_journal_record_dto.dart';
import 'package:between_pages/models/journal/manga_journal_response_dto.dart';
import 'package:between_pages/repositories/auth_repository.dart';
import 'package:between_pages/repositories/manga_journal_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MangaJournalEditPage extends ConsumerStatefulWidget {
  final MangaJournalResponseDTO journal;

  const MangaJournalEditPage({super.key, required this.journal});

  @override
  ConsumerState<MangaJournalEditPage> createState() => _MangaJournalEditPageState();
}

class _MangaJournalEditPageState extends ConsumerState<MangaJournalEditPage> {
  late String _status;
  late int? _currentChapter;
  late int? _currentVolume;
  late int? _rating;
  late String? _readingFormat;
  late String? _personalNotes;
  late String? _favoriteCharacter;
  late String? _favoriteArc;
  bool _isLoading = false;

  final List<String> _statusOptions = ['Pendiente', 'Leyendo', 'Terminado', 'Abandonado'];
  final List<String> _formatOptions = ['Físico', 'Digital', 'Online'];

  @override
  void initState() {
    super.initState();
    final j = widget.journal;
    _status = _mapStatusToUi(j.status ?? 'PENDING');
    _currentChapter = j.currentChapter;
    _currentVolume = j.currentVolume;
    _rating = j.rating;
    _readingFormat = j.readingFormat;
    _personalNotes = j.personalNotes;
    _favoriteCharacter = j.favoriteCharacter;
    _favoriteArc = j.favoriteArc;
  }

  String _mapStatusToUi(String status) {
    return switch (status) {
      'PENDING' => 'Pendiente',
      'READING' => 'Leyendo',
      'FINISHED' => 'Terminado',
      'DROPPED' => 'Abandonado',
      _ => status,
    };
  }

  String _mapStatusToDb(String status) {
    return switch (status) {
      'Pendiente' => 'PENDING',
      'Leyendo' => 'READING',
      'Terminado' => 'FINISHED',
      'Abandonado' => 'DROPPED',
      _ => status,
    };
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final authRepository = ref.read(authRepositoryProvider);
      final journalRepository = ref.read(mangaJournalRepositoryProvider);
      final user = await authRepository.getUserProfile();

      final manga = widget.journal.manga;
      final dto = MangaJournalRecordDTO(
        userId: user.idUser,
        mangaId: manga?.idManga,
        mangadexId: manga?.mangadexId,
        source: manga?.source,
        title: manga?.title,
        mangaka: manga?.mangaka,
        demographic: manga?.demographic,
        genre: manga?.genre,
        description: manga?.description,
        coverUrl: manga?.coverUrl,
        totalChapters: manga?.totalChapters,
        totalVolumes: manga?.totalVolumes,
        publicationStatus: manga?.publicationStatus,
        status: _mapStatusToDb(_status),
        currentChapter: _currentChapter,
        currentVolume: _currentVolume,
        rating: _rating,
        readingFormat: _readingFormat,
        favoriteCharacter: _favoriteCharacter,
        favoriteArc: _favoriteArc,
        personalNotes: _personalNotes,
        startDate: widget.journal.startDate,
        endDate: _status == 'Terminado' ? _formatDate(DateTime.now()) : widget.journal.endDate,
      );

      await journalRepository.saveOrUpdate(dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal actualizado correctamente')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final manga = widget.journal.manga;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Journal'),
        actions: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            TextButton(
              onPressed: _save,
              child: const Text('Guardar'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada y título
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: manga?.coverUrl != null
                      ? CachedNetworkImage(
                          imageUrl: manga!.coverUrl!,
                          width: 100,
                          height: 150,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 100,
                          height: 150,
                          color: colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.auto_stories, size: 40),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        manga?.title ?? 'Sin título',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        manga?.mangaka ?? 'Autor desconocido',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (manga?.genre != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          manga!.genre!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Estado
            _buildSectionTitle('Estado de lectura'),
            Wrap(
              spacing: 8,
              children: _statusOptions.map((status) {
                final isSelected = _status == status;
                return ChoiceChip(
                  label: Text(status),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _status = status),
                  selectedColor: colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: isSelected ? colorScheme.onPrimaryContainer : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Progreso
            _buildSectionTitle('Progreso'),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    label: 'Capítulo actual',
                    value: _currentChapter,
                    onChanged: (v) => setState(() => _currentChapter = v),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField(
                    label: 'Volumen actual',
                    value: _currentVolume,
                    onChanged: (v) => setState(() => _currentVolume = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              label: 'Valoración (1-10)',
              value: _rating,
              onChanged: (v) => setState(() => _rating = v),
              max: 10,
            ),
            const SizedBox(height: 24),

            // Formato
            _buildSectionTitle('Formato de lectura'),
            Wrap(
              spacing: 8,
              children: _formatOptions.map((format) {
                final isSelected = _readingFormat == format;
                return ChoiceChip(
                  label: Text(format),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _readingFormat = format),
                  selectedColor: colorScheme.secondaryContainer,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Personaje favorito
            _buildSectionTitle('Personaje favorito'),
            TextField(
              decoration: const InputDecoration(
                hintText: '¿Quién es tu personaje favorito?',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _favoriteCharacter),
              onChanged: (v) => _favoriteCharacter = v,
            ),
            const SizedBox(height: 16),

            // Arco favorito
            _buildSectionTitle('Arco favorito'),
            TextField(
              decoration: const InputDecoration(
                hintText: '¿Cuál es tu arco/arco favorito?',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _favoriteArc),
              onChanged: (v) => _favoriteArc = v,
            ),
            const SizedBox(height: 24),

            // Notas personales
            _buildSectionTitle('Notas personales'),
            TextField(
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Escribe tus pensamientos sobre este manga...',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _personalNotes),
              onChanged: (v) => _personalNotes = v,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required int? value,
    required Function(int?) onChanged,
    int max = 9999,
  }) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      controller: TextEditingController(text: value?.toString() ?? ''),
      onChanged: (v) {
        final num = int.tryParse(v);
        if (num != null && num >= 0 && num <= max) {
          onChanged(num);
        } else if (v.isEmpty) {
          onChanged(null);
        }
      },
    );
  }
}
