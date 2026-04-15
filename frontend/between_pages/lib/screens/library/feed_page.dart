import 'package:between_pages/models/journal/book_journal_response_dto.dart';
import 'package:between_pages/models/journal/fanfic_journal_response_dto.dart';
import 'package:between_pages/models/journal/manga_journal_response_dto.dart';
import 'package:between_pages/providers/journal/book_journal_provider.dart';
import 'package:between_pages/providers/journal/fanfic_journal_provider.dart';
import 'package:between_pages/providers/journal/manga_journal_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar colapsable
          SliverAppBar(
            floating: true,
            snap: true,
            title: Text(
              'Continuar leyendo',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
            backgroundColor: colorScheme.surface,
          ),

          // Sección: En progreso
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_stories,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'En progreso',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tres recuadros en fila: Libros, Fanfics, Manga
          const _InProgressGridSection(),

          // Espacio al final
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

/// Sección con 3 recuadros en fila: Libros, Fanfics, Manga en progreso
class _InProgressGridSection extends ConsumerWidget {
  const _InProgressGridSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(bookJournalProvider);
    final fanficsAsync = ref.watch(fanficJournalProvider);
    final mangasAsync = ref.watch(mangaJournalProvider);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Column(
              children: [
                // Recuadro Libros
                _ProgressCard(
                  title: 'Libros',
                  icon: Icons.book,
                  color: Colors.blue,
                  asyncValue: booksAsync,
                  onTap: (item) => context.push(
                    '/book/${item.book.idBook}',
                    extra: item.book,
                  ),
                  getCoverUrl: (item) =>
                      (item as BookJournalResponseDto).book.coverUrl,
                  getTitle: (item) =>
                      (item as BookJournalResponseDto).book.title,
                ),
                const SizedBox(height: 12),
                // Recuadro Fanfics
                _ProgressCard(
                  title: 'Fanfics',
                  icon: Icons.favorite,
                  color: Colors.pink,
                  asyncValue: fanficsAsync,
                  onTap: (item) => context.push(
                    '/fanfic/${item.fanfic.idFanfic}',
                    extra: item.fanfic,
                  ),
                  getCoverUrl: (item) =>
                      (item as FanficJournalResponseDTO).fanfic.coverUrl,
                  getTitle: (item) =>
                      (item as FanficJournalResponseDTO).fanfic.title ??
                      'Sin título',
                ),
                const SizedBox(height: 12),
                // Recuadro Manga
                _ProgressCard(
                  title: 'Manga',
                  icon: Icons.menu_book,
                  color: Colors.orange,
                  asyncValue: mangasAsync,
                  onTap: (item) {
                    final manga = (item as MangaJournalResponseDTO).manga;
                    if (manga != null) {
                      final id =
                          manga.idManga?.toString() ?? manga.mangadexId ?? '';
                      if (id.isNotEmpty) {
                        context.push('/manga/$id', extra: manga);
                      }
                    }
                  },
                  getCoverUrl: (item) =>
                      (item as MangaJournalResponseDTO).manga?.coverUrl,
                  getTitle: (item) =>
                      (item as MangaJournalResponseDTO).manga?.title ??
                      'Sin título',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Card individual para cada tipo de contenido en progreso
class _ProgressCard<T> extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final AsyncValue<List<T>> asyncValue;
  final void Function(T) onTap;
  final String? Function(T) getCoverUrl;
  final String Function(T) getTitle;

  const _ProgressCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.asyncValue,
    required this.onTap,
    required this.getCoverUrl,
    required this.getTitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          // Contenido
          Expanded(
            child: asyncValue.when(
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 32,
                          color: colorScheme.outline.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vacío',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colorScheme.outline),
                        ),
                      ],
                    ),
                  );
                }

                final firstItem = items.first;
                final coverUrl = getCoverUrl(firstItem);
                final itemTitle = getTitle(firstItem);

                return InkWell(
                  onTap: () => onTap(firstItem),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      children: [
                        // Portada
                        Expanded(
                          child: Container(
                            width: double.infinity,
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
                            child: coverUrl != null && coverUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: coverUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      color:
                                          colorScheme.surfaceContainerHighest,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      color:
                                          colorScheme.surfaceContainerHighest,
                                      child: Icon(
                                        icon,
                                        size: 32,
                                        color: colorScheme.outline,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: colorScheme.surfaceContainerHighest,
                                    child: Icon(
                                      icon,
                                      size: 32,
                                      color: colorScheme.outline,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Título
                        Text(
                          itemTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        // Contador si hay más
                        if (items.length > 1)
                          Text(
                            '+${items.length - 1} más',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: colorScheme.outline,
                                  fontSize: 10,
                                ),
                          ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (error, _) => Center(
                child: Icon(
                  Icons.error_outline,
                  size: 24,
                  color: colorScheme.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
