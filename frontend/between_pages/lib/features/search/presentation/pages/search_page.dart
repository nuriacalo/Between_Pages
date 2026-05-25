import 'package:between_pages/core/theme/app_colors.dart';
import 'package:between_pages/core/widgets/app_tab_bar.dart';
import 'package:between_pages/features/catalog/application/repositories/fanfic_search_repository.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/catalog/presentation/pages/fanfic_edit_page.dart';
import 'package:between_pages/features/catalog/presentation/widgets/media_list_item.dart';
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

class _SearchPageState extends ConsumerState<SearchPage>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late final TabController _tabController;

  // Tab order matches the rest of the app: Books → Manga → Fanfics
  static const _tabs = [
    SearchContentType.book,
    SearchContentType.manga,
    SearchContentType.fanfic,
  ];

  static const _tabAccents = [
    AppColors.colorLibro,
    AppColors.colorManga,
    AppColors.colorFanfic,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      ref
          .read(unifiedSearchProvider.notifier)
          .setContentType(_tabs[_tabController.index]);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(unifiedSearchProvider.notifier).clear();
    setState(() {});
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final searchState = ref.watch(unifiedSearchProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        titleSpacing: 16,
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            l10n.searchTitle,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(108),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: _SearchField(
                  controller: _searchController,
                  hint: l10n.searchPlaceholder,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: ref.read(unifiedSearchProvider.notifier).search,
                  onClear: _clearSearch,
                ),
              ),
              AnimatedBuilder(
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
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Books
          _TabContent<dynamic>(
            state: searchState,
            results: searchState.bookResults,
            hintMessage: l10n.searchBooksHint,
            emptyMessage: l10n.searchBooksEmpty,
            accent: AppColors.colorLibro,
            icon: Icons.book_rounded,
            itemBuilder: (item) {
              final book = item as BookResponseDTO;
              return MediaListItem(
                item: book,
                onTap: () {
                  final bookId = ((book.idBook ?? 0) > 0)
                      ? (book.idBook ?? 0).toString()
                      : book.googleBooksId ?? 'unknown';
                  context.push('/item/book/$bookId', extra: book);
                },
              );
            },
          ),

          // Manga
          _TabContent<dynamic>(
            state: searchState,
            results: searchState.mangaResults,
            hintMessage: l10n.searchMangasHint,
            emptyMessage: l10n.searchMangasEmpty,
            accent: AppColors.colorManga,
            icon: Icons.menu_book_rounded,
            itemBuilder: (item) {
              final manga = item as MangaResponseDTO;
              final int? mId = manga.idManga;
              final String mangaId = (mId != null && mId > 0)
                  ? mId.toString()
                  : manga.malId?.toString() ?? 'unknown';
              return MediaListItem(
                item: manga,
                onTap: () => context.push('/item/manga/$mangaId', extra: manga),
              );
            },
          ),

          // Fanfics
          _TabContent<dynamic>(
            state: searchState,
            results: searchState.fanficResults,
            hintMessage: l10n.searchFanficsHint,
            emptyMessage: l10n.searchFanficsEmpty,
            accent: AppColors.colorFanfic,
            icon: Icons.favorite_rounded,
            itemBuilder: (item) {
              final fanfic = item as FanfictionResponseDTO;
              return MediaListItem(
                item: fanfic,
                onTap: () => context.push(
                  '/item/fanfic/${fanfic.idFanfic}',
                  extra: fanfic,
                ),
              );
            },
            // Fanfic-specific: "not found" options when results are empty
            emptyWidget: _FanficNotFound(
              l10n: l10n,
              onImportAo3: () => _showAo3Sheet(context, l10n),
              onImportManually: () => _importManually(context),
            ),
          ),
        ],
      ),
    );
  }

  // ── AO3 import ────────────────────────────────────────────────────────────

  void _showAo3Sheet(BuildContext context, AppLocalizations l10n) {
    final controller = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.colorFanfic.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.link_rounded,
                    color: AppColors.colorFanfic,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.importAo3Title,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: l10n.importAo3Hint,
                labelText: l10n.importAo3Label,
                prefixIcon: const Icon(
                  Icons.link_rounded,
                  color: AppColors.colorFanfic,
                  size: 18,
                ),
                filled: true,
                fillColor: AppColors.card(context),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.colorFanfic,
                    width: 1.5,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l10n.cancelButton),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _importFromAo3(controller.text);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.colorFanfic,
                    ),
                    child: Text(l10n.importButton),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importFromAo3(String ao3Input) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final fanfic = await ref
          .read(fanficSearchRepositoryProvider)
          .importFromAo3(ao3Input);
      if (!mounted) return;
      context.push('/item/fanfic/${fanfic.idFanfic}', extra: fanfic);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.errorPrefix}: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _importManually(BuildContext context) async {
    final newFanfic = await Navigator.push<FanfictionResponseDTO>(
      context,
      MaterialPageRoute(builder: (_) => const FanficEditPage()),
    );
    if (newFanfic != null && mounted) {
      context.push('/item/fanfic/${newFanfic.idFanfic}', extra: newFanfic);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SearchField
// ─────────────────────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final void Function(String) onChanged;
  final void Function(String) onSubmitted;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textSecondary(context)),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: colorScheme.primary,
          size: 20,
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary(context),
                  size: 18,
                ),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.7),
            width: 1.5,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TypeTabBar  — tabs with per-type accent colour
// ─────────────────────────────────────────────────────────────────────────────

class _TypeTabBar extends StatelessWidget {
  final TabController controller;
  final AppLocalizations l10n;

  const _TypeTabBar({required this.controller, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // The indicator colour follows the selected tab
    final colors = [
      AppColors.colorLibro,
      AppColors.colorManga,
      AppColors.colorFanfic,
    ];

    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        final accent = colors[controller.index];
        return TabBar(
          controller: controller,
          labelColor: accent,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: accent,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 3,
          dividerColor: colorScheme.outlineVariant.withValues(alpha: 0.3),
          tabs: [
            Tab(
              icon: const Icon(Icons.book_rounded, size: 18),
              text: l10n.tabBooks,
            ),
            Tab(
              icon: const Icon(Icons.menu_book_rounded, size: 18),
              text: l10n.tabMangas,
            ),
            Tab(
              icon: const Icon(Icons.favorite_rounded, size: 18),
              text: l10n.tabFanfics,
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TabContent<T>
//
// Single generic widget that replaces the three identical
// _buildBookResults / _buildMangaResults / _buildFanficResults methods.
// ─────────────────────────────────────────────────────────────────────────────

class _TabContent<T> extends StatelessWidget {
  final UnifiedSearchState state;
  final List<T> results;
  final String hintMessage;
  final String emptyMessage;
  final Color accent;
  final IconData icon;
  final Widget Function(T) itemBuilder;
  final Widget? emptyWidget; // override for fanfic "not found" options

  const _TabContent({
    required this.state,
    required this.results,
    required this.hintMessage,
    required this.emptyMessage,
    required this.accent,
    required this.icon,
    required this.itemBuilder,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Loading
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator(color: accent));
    }

    // Error
    if (state.error != null) {
      return _ErrorState(error: state.error!, accent: accent);
    }

    // No query yet — hint state
    if (state.query.isEmpty) {
      return _HintState(message: hintMessage, icon: icon, accent: accent);
    }

    // Query but no results
    if (results.isEmpty) {
      return emptyWidget ??
          _EmptyResults(message: emptyMessage, icon: icon, accent: accent);
    }

    // Results list
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (_, i) => itemBuilder(results[i]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// State widgets
// ─────────────────────────────────────────────────────────────────────────────

class _HintState extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color accent;

  const _HintState({
    required this.message,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 32, color: accent.withValues(alpha: 0.55)),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary(context),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _EmptyResults extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color accent;

  const _EmptyResults({
    required this.message,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: accent.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary(context),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  final String error;
  final Color accent;

  const _ErrorState({required this.error, required this.accent});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Algo salió mal',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _FanficNotFound  — import options when fanfic search returns empty
// ─────────────────────────────────────────────────────────────────────────────

class _FanficNotFound extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onImportAo3;
  final VoidCallback onImportManually;

  const _FanficNotFound({
    required this.l10n,
    required this.onImportAo3,
    required this.onImportManually,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    const accent = AppColors.colorFanfic;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: accent.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.searchFanficsEmpty,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.importOtherWay,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary(context),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // AO3 import
            _ImportOption(
              icon: Icons.link_rounded,
              label: l10n.importAo3Link,
              accent: accent,
              filled: true,
              isDark: isDark,
              onTap: onImportAo3,
            ),
            const SizedBox(height: 10),

            // Manual import
            _ImportOption(
              icon: Icons.edit_rounded,
              label: l10n.importManual,
              accent: accent,
              filled: false,
              isDark: isDark,
              onTap: onImportManually,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  final bool filled;
  final bool isDark;
  final VoidCallback onTap;

  const _ImportOption({
    required this.icon,
    required this.label,
    required this.accent,
    required this.filled,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onTap,
          icon: Icon(icon),
          label: Text(label),
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: accent),
        label: Text(label, style: TextStyle(color: accent)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: accent.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
