import 'package:between_pages/models/catalog/book_response_dto.dart';
import 'package:between_pages/models/catalog/manga_response_dto.dart';
import 'package:between_pages/models/journal/book_journal_response_dto.dart';
import 'package:between_pages/models/journal/manga_journal_response_dto.dart';
import 'package:between_pages/providers/journal/book_journal_provider.dart';
import 'package:between_pages/providers/journal/manga_journal_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class JournalPage extends ConsumerWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Journal',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          backgroundColor: colorScheme.surface,
          bottom: TabBar(
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            tabs: const [
              Tab(text: 'Libros'),
              Tab(text: 'Mangas'),
              Tab(text: 'Fanfics'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _BooksTabWithStatus(),
            _MangaTabWithStatus(),
            Center(child: Text('Tus fanfics (Próximamente)')),
          ],
        ),
      ),
    );
  }
}

class _BooksTabWithStatus extends ConsumerWidget {
  const _BooksTabWithStatus();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalsAsync = ref.watch(bookJournalProvider);

    return journalsAsync.when(
      data: (journals) {
        if (journals.isEmpty) {
          return const Center(child: Text('No hay libros en tu Journal.'));
        }

        // Agrupar por estado
        final grouped = _groupBooksByStatus(journals);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatusSection(
              context,
              'Leyendo',
              grouped['READING'] ?? [],
              Colors.green,
            ),
            _buildStatusSection(
              context,
              'Pendientes',
              grouped['PENDING'] ?? [],
              Colors.orange,
            ),
            _buildStatusSection(
              context,
              'Terminados',
              grouped['FINISHED'] ?? [],
              Colors.blue,
            ),
            _buildStatusSection(
              context,
              'Abandonados',
              grouped['DROPPED'] ?? [],
              Colors.red,
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Map<String, List<BookJournalResponseDto>> _groupBooksByStatus(
    List<BookJournalResponseDto> journals,
  ) {
    final grouped = <String, List<BookJournalResponseDto>>{};
    for (final journal in journals) {
      final status = journal.status ?? 'PENDING';
      grouped.putIfAbsent(status, () => []).add(journal);
    }
    return grouped;
  }

  Widget _buildStatusSection(
    BuildContext context,
    String title,
    List<BookJournalResponseDto> journals,
    Color color,
  ) {
    if (journals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${journals.length}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: journals.length,
            itemBuilder: (context, index) {
              final journal = journals[index];
              final book = journal.book;
              return _BookCard(book: book, journal: journal);
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _MangaTabWithStatus extends ConsumerWidget {
  const _MangaTabWithStatus();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalsAsync = ref.watch(mangaJournalProvider);

    return journalsAsync.when(
      data: (journals) {
        if (journals.isEmpty) {
          return const Center(child: Text('No hay mangas en tu Journal.'));
        }

        // Agrupar por estado
        final grouped = _groupMangaByStatus(journals);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatusSection(
              context,
              'Leyendo',
              grouped['READING'] ?? [],
              Colors.green,
            ),
            _buildStatusSection(
              context,
              'Pendientes',
              grouped['PENDING'] ?? [],
              Colors.orange,
            ),
            _buildStatusSection(
              context,
              'Terminados',
              grouped['FINISHED'] ?? [],
              Colors.blue,
            ),
            _buildStatusSection(
              context,
              'Abandonados',
              grouped['DROPPED'] ?? [],
              Colors.red,
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error\n$stack')),
    );
  }

  Map<String, List<MangaJournalResponseDTO>> _groupMangaByStatus(
    List<MangaJournalResponseDTO> journals,
  ) {
    final grouped = <String, List<MangaJournalResponseDTO>>{};
    for (final journal in journals) {
      final status = journal.status ?? 'PENDING';
      grouped.putIfAbsent(status, () => []).add(journal);
    }
    return grouped;
  }

  Widget _buildStatusSection(
    BuildContext context,
    String title,
    List<MangaJournalResponseDTO> journals,
    Color color,
  ) {
    if (journals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${journals.length}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: journals.where((j) => j.manga != null).length,
            itemBuilder: (context, index) {
              final journal = journals
                  .where((j) => j.manga != null)
                  .toList()[index];
              final manga = journal.manga!;
              return _MangaCard(manga: manga, journal: journal);
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _BookCard extends StatelessWidget {
  final BookResponseDTO book;
  final BookJournalResponseDto journal;

  const _BookCard({required this.book, required this.journal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => context.push('/book/${book.idBook}', extra: book),
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 110,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: book.coverUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.book, size: 32),
                          ),
                        )
                      : Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.book, size: 32),
                        ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                book.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (journal.currentPage != null && journal.currentPage! > 0)
                Text(
                  'Pág. ${journal.currentPage}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MangaCard extends StatelessWidget {
  final MangaResponseDTO manga;
  final MangaJournalResponseDTO journal;

  const _MangaCard({required this.manga, required this.journal});

  @override
  Widget build(BuildContext context) {
    // Navegar usando idManga si existe, o mangadexId si no
    final String navigationId =
        manga.idManga?.toString() ?? manga.mangadexId ?? '';

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: navigationId.isNotEmpty
            ? () => context.push('/manga/$navigationId', extra: manga)
            : null,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 110,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: manga.coverUrl != null && manga.coverUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: manga.coverUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.auto_stories, size: 32),
                          ),
                        )
                      : Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.auto_stories, size: 32),
                        ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                manga.title ?? 'Sin título',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (journal.currentChapter != null && journal.currentChapter! > 0)
                Text(
                  'Cap. ${journal.currentChapter}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
