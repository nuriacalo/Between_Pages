import 'package:between_pages/features/catalog/application/repositories/fanfic_search_repository.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/catalog/presentation/pages/fanfic_edit_page.dart';
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
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: colorScheme.onSurface,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                searchNotifier.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.primary.withOpacity(0.7),
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
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
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorWeight: 3.0,
                  dividerColor: colorScheme.outlineVariant.withOpacity(0.3),
                  tabs: [
                    Tab(icon: const Icon(Icons.book), text: l10n.tabBooks),
                    Tab(
                      icon: const Icon(Icons.menu_book),
                      text: l10n.tabFanfics,
                    ),
                    Tab(
                      icon: const Icon(Icons.auto_stories),
                      text: l10n.tabMangas,
                    ),
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
          ],
        ),
      );
    }

    if (state.query.isEmpty) {
      return _buildEmptyState(l10n.searchBooksHint, colorScheme, textTheme);
    }

    if (state.bookResults.isEmpty) {
      return _buildEmptyState(l10n.searchBooksEmpty, colorScheme, textTheme);
    }

    return _buildResultsGrid(
      state.bookResults,
      colorScheme,
      textTheme,
      (book) => CatalogItemCard(
        title: book.title.isEmpty ? l10n.noTitle : book.title,
        author: book.author.isEmpty ? l10n.unknownAuthor : book.author,
        coverUrl: book.coverUrl,
        fallbackIcon: Icons.book,
        onTap: () {
          final bookId = ((book.idBook ?? 0) > 0)
              ? (book.idBook ?? 0).toString()
              : book.googleBooksId ?? 'unknown';
          context.push('/item/book/$bookId', extra: book);
        },
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
            Text('${l10n.errorPrefix}: ${state.error}'),
          ],
        ),
      );
    }

    if (state.query.isEmpty) {
      return _buildEmptyState(l10n.searchFanficsHint, colorScheme, textTheme);
    }

    if (state.fanficResults.isEmpty) {
      return _buildFanficNotFoundOptions(colorScheme, textTheme, l10n);
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
        onTap: () =>
            context.push('/item/fanfic/${fanfic.idFanfic}', extra: fanfic),
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
      return _buildEmptyState(l10n.searchMangasHint, colorScheme, textTheme);
    }

    if (state.mangaResults.isEmpty) {
      return _buildEmptyState(l10n.searchMangasEmpty, colorScheme, textTheme);
    }

    return _buildResultsGrid(state.mangaResults, colorScheme, textTheme, (
      manga,
    ) {
      final int? mId = manga.idManga;
      final mangaId = (mId != null && mId > 0)
          ? mId.toString()
          : manga.malId?.toString() ?? 'unknown';

      return CatalogItemCard(
        title: manga.title ?? l10n.noTitle,
        author: manga.author ?? l10n.unknownAuthor,
        coverUrl: manga.coverUrl,
        fallbackIcon: Icons.auto_stories,
        onTap: () => context.push('/item/manga/$mangaId', extra: manga),
      );
    });
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

  Widget _buildFanficNotFoundOptions(
    ColorScheme colorScheme,
    TextTheme textTheme,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              l10n.searchFanficsEmpty,
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.importOtherWay,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _showLinkImportDialog,
                icon: const Icon(Icons.link),
                label: Text(l10n.importAo3Link),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _importManually,
                icon: const Icon(Icons.edit),
                label: Text(l10n.importManual),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLinkImportDialog() {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importAo3Title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: l10n.importAo3Hint,
            labelText: l10n.importAo3Label,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _importFromAo3(controller.text);
            },
            child: Text(l10n.importButton),
          ),
        ],
      ),
    );
  }

  Future<void> _importFromAo3(String ao3Input) async {
    try {
      final repository = ref.read(fanficSearchRepositoryProvider);
      final fanfic = await repository.importFromAo3(ao3Input);
      if (!mounted) return;
      context.push('/item/fanfic/${fanfic.idFanfic}', extra: fanfic);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.errorPrefix}: $e')));
    }
  }

  void _importManually() async {
    final newFanfic = await Navigator.push<FanfictionResponseDTO>(
      context,
      MaterialPageRoute(builder: (_) => const FanficEditPage()),
    );

    if (newFanfic != null && mounted) {
      context.push('/item/fanfic/${newFanfic.idFanfic}', extra: newFanfic);
    }
  }

  Widget _buildResultsGrid<T>(
    List<T> items,
    ColorScheme colorScheme,
    TextTheme textTheme,
    Widget Function(T) itemBuilder,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
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
