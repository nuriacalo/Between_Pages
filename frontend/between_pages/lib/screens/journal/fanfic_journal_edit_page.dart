import 'package:between_pages/models/journal/fanfic_journal_record_dto.dart';
import 'package:between_pages/models/journal/fanfic_journal_response_dto.dart';
import 'package:between_pages/providers/journal/fanfic_journal_provider.dart';
import 'package:between_pages/repositories/auth_repository.dart';
import 'package:between_pages/repositories/fanfic_journal_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:between_pages/repositories/journal_status_helper.dart';

class FanficJournalEditPage extends ConsumerStatefulWidget {
  final FanficJournalResponseDTO journal;

  const FanficJournalEditPage({super.key, required this.journal});

  @override
  ConsumerState<FanficJournalEditPage> createState() =>
      _FanficJournalEditPageState();
}

class _FanficJournalEditPageState extends ConsumerState<FanficJournalEditPage> {
  late String _status;
  late int? _currentChapter;
  late int? _rating;
  late int? _tearDrops;
  late int? _spiceFlames;
  late String? _personalNotes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final j = widget.journal;
    _status = JournalStatusHelper.mapStatusToUi(j.status ?? 'TBR');
    _currentChapter = j.currentChapter;
    _rating = j.rating;
    _tearDrops = j.tearDrops;
    _spiceFlames = j.spiceFlames;
    _personalNotes = j.personalNotes;
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final authRepository = ref.read(authRepositoryProvider);
      final journalRepository = ref.read(fanficJournalRepositoryProvider);
      final user = await authRepository.getUserProfile();

      final fanfic = widget.journal.fanfic;
      final dto = FanficJournalRecordDTO(
        userId: user.idUser,
        fanfictionId: fanfic.idFanfic,
        ao3Id: fanfic.ao3Id,
        title: fanfic.title,
        author: fanfic.author,
        sourceMaterial: fanfic.sourceMaterial,
        description: fanfic.description,
        coverUrl: fanfic.coverUrl,
        genre: fanfic.genre,
        theme: fanfic.theme,
        totalChapters: fanfic.totalChapters,
        publicationStatus: fanfic.publicationStatus,
        status: JournalStatusHelper.mapStatusToDb(_status),
        currentChapter: _currentChapter,
        rating: _rating,
        tearDrops: _tearDrops,
        spiceFlames: _spiceFlames,
        personalNotes: _personalNotes,
        startDate: widget.journal.startDate,
        endDate: _status == 'Terminado'
            ? DateTime.now().toIso8601String()
            : widget.journal.endDate,
      );

      await journalRepository.saveOrUpdate(dto);
      ref.invalidate(fanficJournalProvider);

      if (mounted) {
        // Si se marcó como terminado, abrir la pantalla inmersiva del Diario
        if (_status == 'Terminado' && widget.journal.status != 'FINISHED') {
          context.push('/journal/fanfic/diary', extra: widget.journal);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Journal de Fanfic actualizado')),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fanfic = widget.journal.fanfic;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Journal de Fanfic'),
        actions: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            TextButton(onPressed: _save, child: const Text('Guardar')),
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
                  child: fanfic.coverUrl != null
                      ? CachedNetworkImage(
                          imageUrl: fanfic.coverUrl!,
                          width: 100,
                          height: 150,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 100,
                          height: 150,
                          color: colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.favorite, size: 40),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fanfic.title ?? 'Sin título',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fanfic.author ?? 'Autor desconocido',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Botón Iniciar cronómetro de lectura
            if (_status == 'Leyendo') ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    context.push(
                      '/journal/fanfic/session',
                      extra: widget.journal,
                    );
                  },
                  icon: const Icon(Icons.timer_outlined),
                  label: const Text('Iniciar sesión de lectura'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Estado
            Text(
              'Estado de lectura',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Wrap(
              spacing: 8,
          children: JournalStatusHelper.statusOptions.map((status) {
                final isSelected = _status == status;
                return ChoiceChip(
                  label: Text(status),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _status = status),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Progreso
            Text('Progreso', style: Theme.of(context).textTheme.titleSmall),
            TextField(
              controller: TextEditingController(
                text: _currentChapter?.toString() ?? '',
              ),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Capítulo actual'),
              onChanged: (v) => _currentChapter = int.tryParse(v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(
                text: _rating?.toString() ?? '',
              ),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Valoración (1-10)'),
              onChanged: (v) => _rating = int.tryParse(v),
            ),
            const SizedBox(height: 16),

            // Tear Drops (0-5)
            Text(
              'Lágrimas derramadas',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Wrap(
              spacing: 8,
              children: List.generate(6, (index) {
                final isSelected = _tearDrops == index;
                return ChoiceChip(
                  label: Text('$index 💧'),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _tearDrops = index),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Spice Flames (0-5)
            Text(
              'Nivel de spice',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Wrap(
              spacing: 8,
              children: List.generate(6, (index) {
                final isSelected = _spiceFlames == index;
                return ChoiceChip(
                  label: Text('$index 🔥'),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _spiceFlames = index),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Notas
            Text(
              'Notas personales',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            TextField(
              controller: TextEditingController(text: _personalNotes),
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Escribe tus pensamientos...',
              ),
              onChanged: (v) => _personalNotes = v,
            ),
          ],
        ),
      ),
    );
  }
}
