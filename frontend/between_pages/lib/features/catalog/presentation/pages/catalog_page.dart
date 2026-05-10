import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/catalog/application/providers/all_books_provider.dart';
import 'package:between_pages/features/catalog/application/providers/all_manga_provider.dart';
import 'package:between_pages/features/catalog/application/providers/all_fanfics_provider.dart';
import 'package:between_pages/features/library/presentation/widgets/catalog_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:between_pages/l10n/app_localizations.dart';

class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.catalogTitle,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          backgroundColor: colorScheme.surface,
          bottom: TabBar(
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            tabs: [
              Tab(text: l10n.tabBooks),
              Tab(text: l10n.tabMangas),
              Tab(text: l10n.tabFanfics),
            ],
          ),
        ),
        body: TabBarView(
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
    final l10n = AppLocalizations.of(context)!;
    final booksAsync = ref.watch(allBooksProvider);

    return booksAsync.when(
      data: (books) {
        if (books.isEmpty) {
          return Center(child: Text(l10n.emptyCatalogBooks));
        }
        return _buildGrid(
          books.cast<BookResponseDTO>(),
          (book) => CatalogItemCard(
            title: book.title,
            author: book.author,
            coverUrl: book.coverUrl,
            fallbackIcon: Icons.book,
            onTap: () => context.push('/item/book/${book.idBook}', extra: book),
          ),
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
    final l10n = AppLocalizations.of(context)!;
    final mangaAsync = ref.watch(allMangaProvider);

    return mangaAsync.when(
      data: (mangas) {
        if (mangas.isEmpty) {
          return Center(child: Text(l10n.emptyCatalogMangas));
        }
        return _buildGrid(
          mangas.cast<MangaResponseDTO>(),
          (manga) => CatalogItemCard(
            title: manga.title ?? 'Sin título',
            author: manga.author ?? 'Autor desconocido',
            coverUrl: manga.coverUrl,
            fallbackIcon: Icons.auto_stories,
            onTap: () => context.push('/item/manga/${manga.idManga}', extra: manga),
          ),
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
    final l10n = AppLocalizations.of(context)!;
    final fanficsAsync = ref.watch(allFanficsProvider);

    return fanficsAsync.when(
      data: (fanfics) {
        if (fanfics.isEmpty) {
          return Center(child: Text(l10n.emptyCatalogFanfics));
        }
        return _buildGrid(
          fanfics.cast<FanfictionResponseDTO>(),
          (fanfic) => CatalogItemCard(
            title: fanfic.title ?? 'Sin título',
            author: fanfic.author ?? 'Autor desconocido',
            coverUrl: fanfic.coverUrl,
            fallbackIcon: Icons.favorite,
            isFanfic: true,
            onTap: () => context.push('/item/fanfic/${fanfic.idFanfic}', extra: fanfic),
          ),
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
