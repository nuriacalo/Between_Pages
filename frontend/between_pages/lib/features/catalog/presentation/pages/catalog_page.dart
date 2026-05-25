import 'package:between_pages/core/theme/app_colors.dart';
import 'package:between_pages/core/widgets/app_tab_bar.dart';
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

// Cambia StatelessWidget → StatefulWidget con SingleTickerProviderStateMixin
class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabAccents = [
    AppColors.colorLibro,
    AppColors.colorManga,
    AppColors.colorFanfic,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        title: Text(
          l10n.catalogTitle,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: AnimatedBuilder(
            animation: _tabController.animation!,
            builder: (context, _) {
              final value = _tabController.animation!.value;
              final Color accent;
              if (value <= 0.0) {
                accent = _tabAccents[0];
              } else if (value <= 1.0) {
                accent = Color.lerp(_tabAccents[0], _tabAccents[1], value)!;
              } else {
                accent = Color.lerp(_tabAccents[1], _tabAccents[2], value - 1.0)!;
              }
              return AppTabBar(
                controller: _tabController,
                accent: accent,
                l10n: l10n,
              );
            },
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BooksCatalogTab(),
          _MangaCatalogTab(),
          _FanficsCatalogTab(),
        ],
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
            onTap: () =>
                context.push('/item/manga/${manga.idManga}', extra: manga),
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
            onTap: () =>
                context.push('/item/fanfic/${fanfic.idFanfic}', extra: fanfic),
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
