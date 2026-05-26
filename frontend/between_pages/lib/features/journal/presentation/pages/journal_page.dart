import 'package:between_pages/core/theme/app_colors.dart';
import 'package:between_pages/core/widgets/empty_state.dart';
import 'package:between_pages/features/catalog/presentation/widgets/ownership_badge.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/domain/responses/base_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/book_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/fanfic_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/manga_journal_response_dto.dart';
import 'package:between_pages/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Modelo unificado
// ─────────────────────────────────────────────────────────────────────────────

enum _EntryType { book, manga, fanfic }

class _JournalEntry {
  final int id;
  final _EntryType type;
  final String status;
  final String title;
  final String? author;
  final String? ownership;
  final String? progressLabel;
  final double? progress;
  final int? rating;
  final String? personalNotes;
  final String? mainShip;
  final String? coverUrl;
  final BaseJournalResponseDTO raw;

  const _JournalEntry({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    this.author,
    this.ownership,
    this.progressLabel,
    this.progress,
    this.rating,
    this.personalNotes,
    this.mainShip,
    this.coverUrl,
    required this.raw,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers a nivel de archivo
// ─────────────────────────────────────────────────────────────────────────────

Color _typeColor(_EntryType t) => switch (t) {
  _EntryType.book => AppColors.colorLibro,
  _EntryType.manga => AppColors.colorManga,
  _EntryType.fanfic => AppColors.colorFanfic,
};

String _typeLabel(_EntryType t) => switch (t) {
  _EntryType.book => 'Libro',
  _EntryType.manga => 'Manga',
  _EntryType.fanfic => 'Fanfic',
};

IconData _typeIcon(_EntryType t) => switch (t) {
  _EntryType.book => Icons.book_rounded,
  _EntryType.manga => Icons.menu_book_rounded,
  _EntryType.fanfic => Icons.favorite_rounded,
};

String _ownershipIcon(String ownership) => switch (ownership) {
  'PHYSICAL' => '📚',
  'DIGITAL' => '📱',
  'BORROWED' => '🤝',
  _ => '',
};

// ─────────────────────────────────────────────────────────────────────────────
// Definición de tabs
// ─────────────────────────────────────────────────────────────────────────────

class _TabDef {
  final String label;
  final List<String> statuses;
  final Color color;

  const _TabDef({
    required this.label,
    required this.statuses,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// JournalPage
// ─────────────────────────────────────────────────────────────────────────────

class JournalPage extends ConsumerStatefulWidget {
  const JournalPage({super.key});

  @override
  ConsumerState<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends ConsumerState<JournalPage>
    with TickerProviderStateMixin {
  TabController? _tabController;
  List<_TabDef> _activeTabs = [];

  static const _alwaysTabs = [
    _TabDef(
      label: 'Leyendo',
      statuses: ['READING'],
      color: AppColors.statusReading,
    ),
    _TabDef(
      label: 'Terminado',
      statuses: ['FINISHED'],
      color: AppColors.statusFinished,
    ),
  ];

  static const _conditionalTabs = [
    _TabDef(
      label: 'En pausa',
      statuses: ['PAUSED'],
      color: AppColors.colorManga,
    ),
    _TabDef(
      label: 'Abandonado',
      statuses: ['DROPPED'],
      color: AppColors.statusAbandoned,
    ),
  ];

  void _rebuildTabs(List<_TabDef> newTabs) {
    if (newTabs.length == _activeTabs.length) return;
    _tabController?.dispose();
    _tabController = TabController(length: newTabs.length, vsync: this)
      ..addListener(() => setState(() {}));
    setState(() => _activeTabs = newTabs);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  List<_JournalEntry> _buildEntries(Map<JournalType, List<dynamic>> journals) {
    final entries = <_JournalEntry>[];

    for (final raw in journals[JournalType.book] ?? []) {
      final j = raw as BookJournalResponseDto;
      final pages = j.book.pageCount ?? 0;
      final cur = j.currentPage ?? 0;
      entries.add(
        _JournalEntry(
          id: j.id,
          type: _EntryType.book,
          status: j.status,
          title: j.book.title,
          author: j.book.author,
          coverUrl: j.book.coverUrl,
          ownership: j.ownership,
          progressLabel: cur > 0
              ? 'Pág. $cur${pages > 0 ? ' / $pages' : ''}'
              : null,
          progress: pages > 0 ? (cur / pages).clamp(0.0, 1.0) : null,
          rating: j.rating,
          personalNotes: j.personalNotes,
          raw: j,
        ),
      );
    }

    for (final raw in journals[JournalType.manga] ?? []) {
      final j = raw as MangaJournalResponseDTO;
      final total = j.manga?.totalChapters ?? 0;
      final cur = j.currentChapter ?? 0;
      entries.add(
        _JournalEntry(
          id: j.id,
          type: _EntryType.manga,
          status: j.status,
          title: j.manga?.title ?? 'Sin título',
          author: j.manga?.author,
          coverUrl: j.manga?.coverUrl,
          ownership: j.ownership,
          progressLabel: cur > 0
              ? 'Cap. $cur${total > 0 ? ' / $total' : ''}'
              : null,
          progress: total > 0 ? (cur / total).clamp(0.0, 1.0) : null,
          rating: j.rating,
          personalNotes: j.personalNotes,
          raw: j,
        ),
      );
    }

    for (final raw in journals[JournalType.fanfic] ?? []) {
      final j = raw as FanficJournalResponseDTO;
      final total = j.fanfic.totalChapters ?? 0;
      final cur = j.currentChapter ?? 0;
      entries.add(
        _JournalEntry(
          id: j.id,
          type: _EntryType.fanfic,
          status: j.status,
          title: j.fanfic.title ?? 'Sin título',
          author: j.fanfic.author,
          coverUrl: j.fanfic.coverUrl,
          progressLabel: cur > 0
              ? 'Cap. $cur${total > 0 ? ' / $total' : ''}'
              : null,
          progress: total > 0 ? (cur / total).clamp(0.0, 1.0) : null,
          rating: j.rating,
          personalNotes: j.personalNotes,
          mainShip: j.mainShip,
          raw: j,
        ),
      );
    }

    return entries;
  }

  List<_TabDef> _computeTabs(List<_JournalEntry> entries) {
    bool hasStatus(List<String> statuses) =>
        entries.any((e) => statuses.contains(e.status));

    return [
      _alwaysTabs[0],
      if (hasStatus(_conditionalTabs[0].statuses)) _conditionalTabs[0],
      _alwaysTabs[1],
      if (hasStatus(_conditionalTabs[1].statuses)) _conditionalTabs[1],
    ];
  }

  void _openEntry(BuildContext context, _JournalEntry entry) {
    switch (entry.type) {
      case _EntryType.book:
        context.push('/journal/book/edit', extra: entry.raw);
      case _EntryType.manga:
        context.push('/journal/manga/edit', extra: entry.raw);
      case _EntryType.fanfic:
        context.push('/journal/fanfic/edit', extra: entry.raw);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final journalsAsync = ref.watch(allJournalsProvider);

    return journalsAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.background(context),
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.accent(context),
            strokeWidth: 2,
          ),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background(context),
        body: EmptyState(
          icon: Icons.error_outline,
          title: 'Error al cargar',
          subtitle: e.toString(),
        ),
      ),
      data: (journals) {
        final entries = _buildEntries(journals);
        final tabs = _computeTabs(entries);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _rebuildTabs(tabs);
        });

        if (_tabController == null || _activeTabs.isEmpty) {
          return Scaffold(backgroundColor: AppColors.background(context));
        }

        final currentAccent = _activeTabs[_tabController!.index].color;

        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            backgroundColor: AppColors.surface(context),
            title: Text(
              l10n.journalTitle,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  onPressed: () => context.push('/global-notes'),
                  icon: Icon(
                    Icons.edit_note_rounded,
                    size: 24,
                    color: AppColors.textSecondary(context),
                  ),
                  tooltip: 'Notas Globales',
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(46),
              child: AnimatedBuilder(
                animation: _tabController!,
                builder: (_, _) => TabBar(
                  controller: _tabController,
                  isScrollable: _activeTabs.length > 3,
                  tabAlignment: _activeTabs.length > 3
                      ? TabAlignment.start
                      : TabAlignment.fill,
                  labelColor: currentAccent,
                  unselectedLabelColor: AppColors.textSecondary(context),
                  indicatorColor: currentAccent,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorWeight: 3,
                  dividerColor: AppColors.border(context),
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  tabs: _activeTabs.map((t) => Tab(text: t.label)).toList(),
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: _activeTabs.map((tab) {
              final tabEntries = entries
                  .where((e) => tab.statuses.contains(e.status))
                  .toList();

              if (tabEntries.isEmpty) {
                return EmptyState(
                  icon: Icons.menu_book_rounded,
                  title: 'Nada por aquí',
                  subtitle: 'No tienes lecturas en "${tab.label}" todavía.',
                  actionLabel: l10n.findSomethingToRead,
                  onAction: () => GoRouter.of(context).go('/search'),
                );
              }

              return RefreshIndicator(
                color: AppColors.accent(context),
                onRefresh: () => ref.refresh(allJournalsProvider.future),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  itemCount: tabEntries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _JournalCard(
                    entry: tabEntries[i],
                    onTap: () => _openEntry(context, tabEntries[i]),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _JournalCard
// ─────────────────────────────────────────────────────────────────────────────
class _JournalCard extends StatelessWidget {
  final _JournalEntry entry;
  final VoidCallback onTap;

  const _JournalCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = _typeColor(entry.type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border(context)),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left accent bar ─────────────────────────────────────
              Container(width: 4, color: color),

              // ── Cover ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(10),
                child: _JournalCover(entry: entry, color: color),
              ),

              // ── Contenido ───────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge tipo + rating
                      Row(
                        children: [
                          _JournalTypeBadge(entry: entry, color: color),
                          const Spacer(),
                          if (entry.rating != null)
                            _JournalRatingBadge(
                              rating: entry.rating!,
                              emphasis: AppColors.emphasis(context),
                            ),
                        ],
                      ),
                      const SizedBox(height: 7),

                      // Título
                      Text(
                        entry.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                          height: 1.25,
                        ),
                      ),

                      // Autor
                      if (entry.author != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          entry.author!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],

                      // Ship — solo fanfic
                      if (entry.mainShip != null &&
                          entry.mainShip!.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              Icons.favorite_rounded,
                              size: 10,
                              color: AppColors.colorFanfic.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                entry.mainShip!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelSmall?.copyWith(
                                  color: AppColors.colorFanfic.withValues(
                                    alpha: 0.85,
                                  ),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const Spacer(),

                      // Separador + progreso
                      if (entry.progressLabel != null) ...[
                        Divider(height: 16, color: AppColors.border(context)),
                        if (entry.progress != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: entry.progress,
                              minHeight: 4,
                              backgroundColor: color.withValues(alpha: 0.12),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                          const SizedBox(height: 5),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.progressLabel!,
                              style: textTheme.labelSmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                            if (entry.progress != null)
                              Text(
                                '${(entry.progress! * 100).round()}%',
                                style: textTheme.labelSmall?.copyWith(
                                  color: color.withValues(alpha: 0.65),
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ],

                      // Notas personales
                      if (entry.personalNotes != null &&
                          entry.personalNotes!.isNotEmpty) ...[
                        const SizedBox(height: 7),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.format_quote_rounded,
                              size: 11,
                              color: AppColors.textSecondary(
                                context,
                              ).withValues(alpha: 0.35),
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                entry.personalNotes!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary(
                                    context,
                                  ).withValues(alpha: 0.7),
                                  fontStyle: FontStyle.italic,
                                  fontSize: 11,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _JournalCover
// ─────────────────────────────────────────────────────────────────────────────

class _JournalCover extends StatelessWidget {
  final _JournalEntry entry;
  final Color color;

  const _JournalCover({required this.entry, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 84,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox.expand(
              child: entry.coverUrl != null && entry.coverUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: entry.coverUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          Container(color: color.withValues(alpha: 0.1)),
                      errorWidget: (_, _, _) =>
                          _JournalCoverFallback(color: color, entry: entry),
                    )
                  : _JournalCoverFallback(color: color, entry: entry),
            ),
          ),
          if (entry.ownership != null)
            Positioned(
              top: 5,
              left: 5,
              child: OwnershipBadge(ownership: entry.ownership!),
            ),
        ],
      ),
    );
  }
}

class _JournalCoverFallback extends StatelessWidget {
  final Color color;
  final _JournalEntry entry;

  const _JournalCoverFallback({required this.color, required this.entry});

  @override
  Widget build(BuildContext context) => Container(
    color: color.withValues(alpha: 0.08),
    child: Center(
      child: Icon(
        _typeIcon(entry.type),
        size: 26,
        color: color.withValues(alpha: 0.4),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// _JournalTypeBadge
// ─────────────────────────────────────────────────────────────────────────────

class _JournalTypeBadge extends StatelessWidget {
  final _JournalEntry entry;
  final Color color;

  const _JournalTypeBadge({required this.entry, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_typeIcon(entry.type), size: 9, color: color),
        const SizedBox(width: 3),
        Text(
          _typeLabel(entry.type).toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// _JournalRatingBadge
// ─────────────────────────────────────────────────────────────────────────────

class _JournalRatingBadge extends StatelessWidget {
  final int rating;
  final Color emphasis;

  const _JournalRatingBadge({required this.rating, required this.emphasis});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: emphasis.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: 10, color: emphasis),
        const SizedBox(width: 2),
        Text(
          '$rating',
          style: TextStyle(
            color: emphasis,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
