import 'package:between_pages/models/catalog/book_response_dto.dart';
import 'package:between_pages/models/catalog/manga_response_dto.dart';
import 'package:between_pages/models/catalog/fanfiction_response_dto.dart';
import 'package:between_pages/providers/catalog/all_books_provider.dart';
import 'package:between_pages/providers/catalog/all_manga_provider.dart';
import 'package:between_pages/providers/catalog/all_fanfics_provider.dart';
import 'package:between_pages/screens/catalog/catalog_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Catálogo',
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
            _BooksCatalogTab(),
            _MangaCatalogTab(),
            _FanficsCatalogTab(),
          ],
        ),
      ),
    );
  }
}

class _BooksCatalogTab extends ConsumerWidget {
  const _BooksCatalogTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(allBooksProvider);

    return booksAsync.when(
      data: (books) {
        if (books.isEmpty) {
          return const Center(child: Text('No hay libros en el catálogo.'));
        }
        return _buildGrid(
          books.cast<BookResponseDTO>(),
          (book) => _CatalogBookCard(book: book),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _MangaCatalogTab extends ConsumerWidget {
  const _MangaCatalogTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mangaAsync = ref.watch(allMangaProvider);

    return mangaAsync.when(
      data: (mangas) {
        if (mangas.isEmpty) {
          return const Center(child: Text('No hay mangas en el catálogo.'));
        }
        return _buildGrid(
          mangas.cast<MangaResponseDTO>(),
          (manga) => _CatalogMangaCard(manga: manga),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _FanficsCatalogTab extends ConsumerWidget {
  const _FanficsCatalogTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fanficsAsync = ref.watch(allFanficsProvider);

    return fanficsAsync.when(
      data: (fanfics) {
        if (fanfics.isEmpty) {
          return const Center(child: Text('No hay fanfics en el catálogo.'));
        }
        return _buildGrid(
          fanfics.cast<FanfictionResponseDTO>(),
          (fanfic) => _CatalogFanficCard(fanfic: fanfic),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

Widget _buildGrid<T>(List<T> items, Widget Function(T) itemBuilder) {
  return GridView.builder(
    padding: const EdgeInsets.all(16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      childAspectRatio: 0.65,
      crossAxisSpacing: 12,
      mainAxisSpacing: 16,
    ),
    itemCount: items.length,
    itemBuilder: (context, index) => itemBuilder(items[index]),
  );
}

class _CatalogBookCard extends StatelessWidget {
  final BookResponseDTO book;

  const _CatalogBookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CatalogDetailPage(
              item: book,
              type: CatalogItemType.book,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
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
                        color: colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.book, size: 32),
                      ),
                    )
                  : Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.book, size: 32),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogMangaCard extends StatelessWidget {
  final MangaResponseDTO manga;

  const _CatalogMangaCard({required this.manga});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CatalogDetailPage(
              item: manga,
              type: CatalogItemType.manga,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
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
                        color: colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.auto_stories, size: 32),
                      ),
                    )
                  : Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.auto_stories, size: 32),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            manga.title ?? 'Sin título',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          Text(
            manga.author ?? 'Autor desconocido',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogFanficCard extends StatelessWidget {
  final FanfictionResponseDTO fanfic;

  const _CatalogFanficCard({required this.fanfic});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CatalogDetailPage(
              item: fanfic,
              type: CatalogItemType.fanfic,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: colorScheme.primaryContainer,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.favorite,
                  size: 40,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            fanfic.title ?? 'Sin título',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          Text(
            fanfic.author ?? 'Autor desconocido',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
