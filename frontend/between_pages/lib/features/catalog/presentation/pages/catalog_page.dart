import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/catalog/application/providers/all_books_provider.dart';
import 'package:between_pages/features/catalog/application/providers/all_manga_provider.dart';
import 'package:between_pages/features/catalog/application/providers/all_fanfics_provider.dart';
import 'package:between_pages/features/catalog/presentation/widgets/media_list_item.dart';

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
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 3.0,
            dividerColor: colorScheme.outlineVariant.withValues(alpha:0.3),
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
        return _buildList(
          books.cast<BookResponseDTO>(),
          (book) => MediaListItem(
            item: book,
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
        return _buildList(
          mangas.cast<MangaResponseDTO>(),
          (manga) => MediaListItem(
            item: manga,
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
        return _buildList(
          fanfics.cast<FanfictionResponseDTO>(),
          (fanfic) => MediaListItem(
            item: fanfic,
            onTap: () => context.push('/item/fanfic/${fanfic.idFanfic}', extra: fanfic),
          ),

        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

Widget _buildList<T>(List<T> items, Widget Function(T) itemBuilder) {
  return ListView.builder(
    padding: const EdgeInsets.symmetric(vertical: 10),
    itemCount: items.length,
    itemBuilder: (context, index) => itemBuilder(items[index]),
  );
}
