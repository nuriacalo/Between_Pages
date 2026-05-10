import 'package:between_pages/features/library/presentation/widgets/catalog_item_card.dart';
import 'package:between_pages/features/search/application/providers/unified_search_provider.dart';
import 'package:between_pages/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final searchState = ref.watch(unifiedSearchProvider);
    final searchNotifier = ref.read(unifiedSearchProvider.notifier);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.searchTitle,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          backgroundColor: colorScheme.surface,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: Column(
              children: [
                // Campo de búsqueda
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.searchPlaceholder,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                searchNotifier.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: searchNotifier.search,
                  ),
                ),
                // Tabs
                TabBar(
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  indicatorColor: colorScheme.primary,
                  tabs: [
                    Tab(icon: const Icon(Icons.book), text: l10n.tabBooks),
                    Tab(icon: const Icon(Icons.menu_book), text: l10n.tabFanfics),
                    Tab(icon: const Icon(Icons.auto_stories), text: l10n.tabMangas),
                  ],
                  // ignore: unnecessary_lambdas — readability
                  onTap: (index) {
                    searchNotifier.setContentType(
                      SearchContentType.values[index],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookResults(searchState, colorScheme, textTheme, l10n),
            _buildFanficResults(searchState, colorScheme, textTheme, l10n),
            _buildMangaResults(searchState, colorScheme, textTheme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildBookResults(
    UnifiedSearchState state,
    ColorScheme colorScheme,
    TextTheme textTheme,
    AppLocalizations l10n,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text('${l10n.errorPrefix}: ${state.error}'),
            Text('${l10n.errorPrefix}: ${state.error}'),
          ],
        ),
      );
    }

    if (state.query.isEmpty) {
      return _buildEmptyState(
        l10n.searchBooksHint,
        colorScheme,
        textTheme,
      );
    }

    if (state.bookResults.isEmpty) {
      return _buildEmptyState(
        l10n.searchBooksEmpty,
        colorScheme,
        textTheme,
      );
    }

    return _buildResultsGrid(
      state.bookResults,
      colorScheme,
      textTheme,
      (book) => CatalogItemCard(
        title: book.title,
        author: book.author,
        coverUrl: book.coverUrl,
        fallbackIcon: Icons.book,
        onTap: () => context.push('/item/book/${book.idBook}', extra: book),
      ),
    );
  }

  Widget _buildFanficResults(
    UnifiedSearchState state,
    ColorScheme colorScheme,
    TextTheme textTheme,
    AppLocalizations l10n,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text('Error: ${state.error}'),
          ],
        ),
      );
    }

    if (state.query.isEmpty) {
      return _buildEmptyState(
        l10n.searchFanficsHint,
        colorScheme,
        textTheme,
      );
    }

    if (state.fanficResults.isEmpty) {
      return _buildEmptyState(
        l10n.searchFanficsEmpty,
        colorScheme,
        textTheme,
      );
    }

    return _buildResultsGrid(
      state.fanficResults,
      colorScheme,
      textTheme,
      (fanfic) => CatalogItemCard(
        title: fanfic.title ?? l10n.noTitle,
        author: fanfic.author ?? l10n.unknownAuthor,
        coverUrl: fanfic.coverUrl,
        fallbackIcon: Icons.favorite,
        isFanfic: true,
        onTap: () => context.push('/item/fanfic/${fanfic.idFanfic}', extra: fanfic),
      ),
    );
  }

  Widget _buildMangaResults(
    UnifiedSearchState state,
    ColorScheme colorScheme,
    TextTheme textTheme,
    AppLocalizations l10n,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text('${l10n.errorPrefix}: ${state.error}'),
          ],
        ),
      );
    }

    if (state.query.isEmpty) {
      return _buildEmptyState(
        l10n.searchMangasHint,
        colorScheme,
        textTheme,
      );
    }

    if (state.mangaResults.isEmpty) {
      return _buildEmptyState(
        l10n.searchMangasEmpty,
        colorScheme,
        textTheme,
      );
    }

    return _buildResultsGrid(
      state.mangaResults,
      colorScheme,
      textTheme,
      (manga) {
        final int? mId = manga.idManga;
        final mangaId = (mId != null && mId > 0)
            ? mId.toString()
            : manga.malId?.toString() ?? 'unknown';
            
        return CatalogItemCard(
          title: manga.title?.toString() ?? l10n.noTitle,
          author: manga.author?.toString() ?? l10n.unknownAuthor,
          coverUrl: manga.coverUrl,
          fallbackIcon: Icons.auto_stories,
          onTap: () => context.push('/item/manga/$mangaId', extra: manga),
        );
      }
    );
  }

  Widget _buildEmptyState(
    String message,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            message,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsGrid<T>(
    List<T> items,
    ColorScheme colorScheme,
    TextTheme textTheme,
    Widget Function(T) itemBuilder,
  ) {
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
}
