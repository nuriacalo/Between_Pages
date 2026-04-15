import 'package:between_pages/models/catalog/manga_response_dto.dart';
import 'package:between_pages/models/journal/manga_journal_record_dto.dart';
import 'package:between_pages/repositories/auth_repository.dart';
import 'package:between_pages/repositories/manga_journal_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MangaDetailPage extends ConsumerStatefulWidget {
  final MangaResponseDTO manga;

  const MangaDetailPage({super.key, required this.manga});

  @override
  ConsumerState<MangaDetailPage> createState() => _MangaDetailPageState();
}

class _MangaDetailPageState extends ConsumerState<MangaDetailPage> {
  bool _isLoading = false;

  String get _title => widget.manga.title ?? 'Título desconocido';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final manga = widget.manga;

    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada en grande
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: manga.coverUrl != null && manga.coverUrl!.isNotEmpty
                    ? Image.network(
                        manga.coverUrl!,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 250,
                          width: 170,
                          color: colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.auto_stories, size: 80),
                        ),
                      )
                    : Container(
                        height: 250,
                        width: 170,
                        color: colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.auto_stories, size: 80),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Botón para añadir al journal
            Center(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _showAddToJournalDialog(),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: const Text('Añadir a mi journal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Título y Autor
            Center(
              child: Text(
                _title,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                manga.mangaka ?? 'Autor desconocido',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Información adicional
            if (manga.demographic != null) ...[
              _InfoRow(label: 'Demografía', value: manga.demographic!),
            ],
            if (manga.genre != null) ...[
              _InfoRow(label: 'Género', value: manga.genre!),
            ],
            if (manga.totalChapters != null) ...[
              _InfoRow(label: 'Capítulos', value: '${manga.totalChapters}'),
            ],
            if (manga.totalVolumes != null) ...[
              _InfoRow(label: 'Volúmenes', value: '${manga.totalVolumes}'),
            ],
            if (manga.publicationStatus != null) ...[
              _InfoRow(label: 'Estado', value: manga.publicationStatus!),
            ],

            const SizedBox(height: 24),

            // Descripción
            if (manga.description != null && manga.description!.isNotEmpty) ...[
              Text(
                'Descripción',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(manga.description!, style: textTheme.bodyLarge),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddToJournalDialog() {
    final statuses = ['Pendiente', 'Leyendo', 'Terminado', 'Abandonado'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses
              .map(
                (status) => ListTile(
                  title: Text(status),
                  leading: Icon(_getStatusIcon(status)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addToJournal(status);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _addToJournal(String status) async {
    setState(() => _isLoading = true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final journalRepository = ref.read(mangaJournalRepositoryProvider);

      final user = await authRepository.getUserProfile();
      final manga = widget.manga;

      final dto = MangaJournalRecordDTO(
        userId: user.idUser,
        mangaId: (manga.idManga != null && manga.idManga! > 0)
            ? manga.idManga
            : null,
        mangadexId: manga.mangadexId,
        source: manga.source,
        title: manga.title,
        mangaka: manga.mangaka,
        demographic: manga.demographic,
        genre: manga.genre,
        description: manga.description,
        coverUrl: manga.coverUrl,
        totalChapters: manga.totalChapters,
        totalVolumes: manga.totalVolumes,
        publicationStatus: manga.publicationStatus,
        status: status,
        startDate: status == 'Leyendo' ? _formatDate(DateTime.now()) : null,
      );

      await journalRepository.saveOrUpdate(dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Añadido al journal correctamente'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pendiente':
        return Icons.bookmark_border;
      case 'Leyendo':
        return Icons.menu_book;
      case 'Terminado':
        return Icons.check_circle;
      case 'Abandonado':
        return Icons.cancel;
      default:
        return Icons.book;
    }
  }

  String _formatDate(DateTime date) {
    // Formato yyyy-MM-dd para LocalDate de Java
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
