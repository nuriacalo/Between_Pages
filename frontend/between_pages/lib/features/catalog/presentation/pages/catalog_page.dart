import 'package:between_pages/core/theme/app_colors.dart';
import 'package:between_pages/core/widgets/app_tab_bar.dart';
import 'package:between_pages/features/catalog/application/providers/enriched_catalog_provider.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/enriched_catalog_item.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/catalog/presentation/widgets/media_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:between_pages/l10n/app_localizations.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> with SingleTickerProviderStateMixin {
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
      body: Consumer(
        builder: (context, ref, child) {
          final enrichedItemsAsync = ref.watch(enrichedCatalogProvider);
          return enrichedItemsAsync.when(
            data: (items) {
              final books = items.where((i) => i.item is BookResponseDTO).toList();
              final mangas = items.where((i) => i.item is MangaResponseDTO).toList();
              final fanfics = items.where((i) => i.item is FanfictionResponseDTO).toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildCatalogTab(books, l10n.emptyCatalogBooks),
                  _buildCatalogTab(mangas, l10n.emptyCatalogMangas),
                  _buildCatalogTab(fanfics, l10n.emptyCatalogFanfics),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          );
        },
      ),
    );
  }

  Widget _buildCatalogTab(List<EnrichedCatalogItem> items, String emptyMessage) {
    final l10n = AppLocalizations.of(context)!;
    if (items.isEmpty) {
      return Center(child: Text(emptyMessage));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final enrichedItem = items[index];
        return MediaListItem(
          item: enrichedItem.item,
          status: enrichedItem.journal?.status ?? 'TBR', // Asignar 'TBR' si el journal es nulo
          onTap: () => context.push(
            '/item/${_getItemPath(enrichedItem.item)}/${_getItemId(enrichedItem.item)}',
            extra: enrichedItem,
          ),
        );
      },
    );
  }

  String _getItemPath(dynamic item) {
    if (item is BookResponseDTO) return 'book';
    if (item is MangaResponseDTO) return 'manga';
    if (item is FanfictionResponseDTO) return 'fanfic';
    return '';
  }

  int _getItemId(dynamic item) {
    if (item is BookResponseDTO) return item.idBook ?? 0;
    if (item is MangaResponseDTO) return item.idManga ?? 0;
    if (item is FanfictionResponseDTO) return item.idFanfic ?? 0;
    return 0;
  }
}
