import 'package:between_pages/l10n/app_localizations.dart';
import 'package:between_pages/providers/search/unified_search_provider.dart';
import 'package:between_pages/widgets/catalog/catalog_item_card.dart';
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
                  tabs: const [
                    Tab(icon: Icon(Icons.book), text: 'Libros'),
                    Tab(icon: Icon(Icons.menu_book), text: 'Fanfics'),
                    Tab(icon: Icon(Icons.auto_stories), text: 'Manga'),
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
            _buildBookResults(searchState, colorScheme, textTheme),
            _buildFanficResults(searchState, colorScheme, textTheme),
            _buildMangaResults(searchState, colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildBookResults(
    UnifiedSearchState state,
    ColorScheme colorScheme,
    TextTheme textTheme,
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
        'Busca libros por título o autor',
        colorScheme,
        textTheme,
      );
    }

    if (state.bookResults.isEmpty) {
      return _buildEmptyState(
        'No se encontraron libros',
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
        author: book.author ?? 'Autor desconocido',
        coverUrl: book.coverUrl,
        fallbackIcon: Icons.book,
        onTap: () => context.push('/book/${book.idBook}', extra: book),
      ),
    );
  }

  Widget _buildFanficResults(
    UnifiedSearchState state,
    ColorScheme colorScheme,
    TextTheme textTheme,
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
        'Busca fanfics por título o autor',
        colorScheme,
        textTheme,
      );
    }

    if (state.fanficResults.isEmpty) {
      return _buildEmptyState(
        'No se encontraron fanfics',
        colorScheme,
        textTheme,
      );
    }

    return _buildResultsGrid(
      state.fanficResults,
      colorScheme,
      textTheme,
      (fanfic) => CatalogItemCard(
        title: fanfic.title ?? 'Sin título',
        author: fanfic.author ?? 'Autor desconocido',
        coverUrl: fanfic.coverUrl,
        fallbackIcon: Icons.favorite,
        isFanfic: true,
        onTap: () => context.push('/journal/fanfic/edit', extra: fanfic), // TODO ruta detalle
      ),
    );
  }

  Widget _buildMangaResults(
    UnifiedSearchState state,
    ColorScheme colorScheme,
    TextTheme textTheme,
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
        'Busca manga por título o autor',
        colorScheme,
        textTheme,
      );
    }

    if (state.mangaResults.isEmpty) {
      return _buildEmptyState(
        'No se encontraron manga',
        colorScheme,
        textTheme,
      );
    }

    return _buildResultsGrid(
      state.mangaResults,
      colorScheme,
      textTheme,
      (manga) {
        final mangaId = (manga.idManga != null && manga.idManga! > 0)
            ? manga.idManga.toString()
            : manga.malId?.toString() ?? 'unknown';
            
        return CatalogItemCard(
          title: manga.title,
          author: manga.author ?? 'Autor desconocido',
          coverUrl: manga.coverUrl,
          fallbackIcon: Icons.auto_stories,
          onTap: () => context.push('/manga/$mangaId', extra: manga),
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
