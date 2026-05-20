import 'package:between_pages/core/widgets/empty_state.dart';
import 'package:between_pages/features/catalog/presentation/widgets/ownership_badge.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/domain/responses/base_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/book_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/fanfic_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/manga_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/utils/journal_status_extensions.dart';
import 'package:between_pages/features/profile/application/providers/gamification_provider.dart';
import 'package:between_pages/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Domain-layer wrapper – merges the three journal types into one list
// ─────────────────────────────────────────────────────────────────────────────

enum _ContentType { book, manga, fanfic }

class _ReadingItem {
  final _ContentType type;
  final BaseJournalResponseDTO journal;
  final String title;
  final String? coverUrl;
  final String? ownership;
  final double progress; // 0.0 – 1.0
  final String progressLabel; // e.g. "Pág. 423"
  final String progressPercent; // e.g. "62%"

  const _ReadingItem({
    required this.type,
    required this.journal,
    required this.title,
    this.coverUrl,
    this.ownership,
    required this.progress,
    required this.progressLabel,
    required this.progressPercent,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// FeedPage
// ─────────────────────────────────────────────────────────────────────────────

class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 6) return l10n.greetingNight;
    if (hour < 12) return l10n.greetingMorning;
    if (hour < 19) return l10n.greetingAfternoon;
    return l10n.greetingNight;
  }

  // Build a unified, sorted list of in-progress items.
  List<_ReadingItem> _buildReadingItems(
    List<dynamic> books,
    List<dynamic> mangas,
    List<dynamic> fanfics,
  ) {
    final items = <_ReadingItem>[];

    for (final raw in books.whereType<BookJournalResponseDto>()) {
      if (!raw.status.isInProgress) continue;
      final pages = raw.book.pageCount ?? 1;
      final cur = raw.currentPage ?? 0;
      final p = (cur / (pages > 0 ? pages : 1)).clamp(0.0, 1.0);
      items.add(_ReadingItem(
        type: _ContentType.book,
        journal: raw,
        title: raw.book.title,
        coverUrl: raw.book.coverUrl,
        ownership: raw.ownership,
        progress: p,
        progressLabel: 'Pág. $cur',
        progressPercent: '${(p * 100).round()}%',
      ));
    }

    for (final raw in mangas.whereType<MangaJournalResponseDTO>()) {
      if (!raw.status.isInProgress) continue;
      final total = raw.manga?.totalChapters ?? 1;
      final cur = raw.currentChapter ?? 0;
      final p = (cur / (total > 0 ? total : 1)).clamp(0.0, 1.0);
      items.add(_ReadingItem(
        type: _ContentType.manga,
        journal: raw,
        title: raw.manga?.title ?? 'Sin título',
        coverUrl: raw.manga?.coverUrl,
        ownership: raw.ownership,
        progress: p,
        progressLabel: 'Cap. $cur',
        progressPercent: '${(p * 100).round()}%',
      ));
    }

    for (final raw in fanfics.whereType<FanficJournalResponseDTO>()) {
      if (!raw.status.isInProgress) continue;
      final total = raw.fanfic.totalChapters ?? 1;
      final cur = raw.currentChapter ?? 0;
      final p = (cur / (total > 0 ? total : 1)).clamp(0.0, 1.0);
      items.add(_ReadingItem(
        type: _ContentType.fanfic,
        journal: raw,
        title: raw.fanfic.title ?? 'Sin título',
        coverUrl: raw.fanfic.coverUrl,
        progress: p,
        progressLabel: 'Cap. $cur',
        progressPercent: '${(p * 100).round()}%',
      ));
    }

    return items;
  }

  Future<void> _openJournal(
    BuildContext context,
    WidgetRef ref,
    _ReadingItem item,
  ) async {
    switch (item.type) {
      case _ContentType.book:
        await context.push('/journal/book/progress', extra: item.journal);
        ref.invalidate(journalProvider(JournalType.book));
      case _ContentType.manga:
        await context.push('/journal/manga/session', extra: item.journal);
        ref.invalidate(journalProvider(JournalType.manga));
      case _ContentType.fanfic:
        await context.push('/journal/fanfic/session', extra: item.journal);
        ref.invalidate(journalProvider(JournalType.fanfic));
    }

    // El feed construye su progreso desde `allJournalsProvider`, por eso hay que
    // refrescarlo al volver de la sesión.
    ref.invalidate(allJournalsProvider);

    ref.invalidate(gamificationProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Providers
    final allJournalsAsync = ref.watch(allJournalsProvider);
    final booksAsync =
        allJournalsAsync.whenData((j) => j[JournalType.book] ?? []);
    final mangasAsync =
        allJournalsAsync.whenData((j) => j[JournalType.manga] ?? []);
    final fanficsAsync =
        allJournalsAsync.whenData((j) => j[JournalType.fanfic] ?? []);

    final gamification = ref.watch(gamificationProvider).valueOrNull;
    final goal = gamification?.annualGoal ?? 12;
    final currentStreak = gamification?.currentStreak ?? 0;
    final weekActivity = gamification?.weekActivity ?? List.filled(7, false);

    final finishedBooks = booksAsync.whenOrNull(
          data: (list) => list
              .whereType<BookJournalResponseDto>()
              .where((b) => b.status.isFinished)
              .length,
        ) ??
        0;

    // Build unified reading list
    final readingItems = _buildReadingItems(
      booksAsync.valueOrNull ?? [],
      mangasAsync.valueOrNull ?? [],
      fanficsAsync.valueOrNull ?? [],
    );

    final isLoading = allJournalsAsync.isLoading;
    final allEmpty = !isLoading &&
        (booksAsync.valueOrNull?.isEmpty ?? true) &&
        (mangasAsync.valueOrNull?.isEmpty ?? true) &&
        (fanficsAsync.valueOrNull?.isEmpty ?? true);

    if (allEmpty) {
      return EmptyState(
        icon: Icons.shelves,
        title: 'Tu biblioteca está vacía',
        subtitle: 'Añade un libro, manga o fanfic para comenzar tu aventura.',
        actionLabel: 'Buscar algo que leer',
        onAction: () => GoRouter.of(context).go('/search'),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        color: colorScheme.primary,
        onRefresh: () async {
          await ref.refresh(allJournalsProvider.future);
          await ref.refresh(gamificationProvider.future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── AppBar ─────────────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor: colorScheme.surface,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(l10n),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Between Pages',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Stats row (goal + streak side by side) ─────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 4,
                        child: _GoalCard(
                          booksRead: finishedBooks,
                          goal: goal,
                          onEdit: () async {
                            final newGoal = await showDialog<int>(
                              context: context,
                              builder: (_) =>
                                  EditReadingGoalDialog(currentGoal: goal),
                            );
                            if (newGoal != null) {
                              ref
                                  .read(gamificationProvider.notifier)
                                  .updateGoal(newGoal);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 5,
                        child: _StreakCard(
                          streak: currentStreak,
                          weekActivity: weekActivity,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── "Leyendo ahora" header ─────────────────────────────────────
            if (readingItems.isNotEmpty || isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Row(
                    children: [
                      _SectionAccent(color: colorScheme.primary),
                      const SizedBox(width: 10),
                      Text(
                        l10n.inProgressTitle,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (readingItems.length > 1)
                        Text(
                          '${readingItems.length} activos',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            // ── Hero card – most prominent item ────────────────────────────
            if (readingItems.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _HeroReadingCard(
                    item: readingItems.first,
                    onTap: () => _openJournal(context, ref, readingItems.first),
                  ),
                ),
              ),

            // ── Carousel with chip filter (remaining items) ────────────────
            if (readingItems.length > 1)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _InProgressCarousel(
                    items: readingItems.skip(1).toList(),
                    onTap: (item) => _openJournal(context, ref, item),
                  ),
                ),
              ),

            // ── Loading indicator ──────────────────────────────────────────
            if (isLoading && readingItems.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child:
                      Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

// Colours per content type – pull from your AppColors / CustomColors if preferred
Color _typeColor(_ContentType t) => switch (t) {
      _ContentType.book => const Color(0xFF7F8C95),
      _ContentType.manga => const Color(0xFFE8A87C),
      _ContentType.fanfic => const Color(0xFFD4A0A4),
    };

IconData _typeIcon(_ContentType t) => switch (t) {
      _ContentType.book => Icons.book_rounded,
      _ContentType.manga => Icons.menu_book_rounded,
      _ContentType.fanfic => Icons.favorite_rounded,
    };

String _typeLabel(_ContentType t) => switch (t) {
      _ContentType.book => 'Libro',
      _ContentType.manga => 'Manga',
      _ContentType.fanfic => 'Fanfic',
    };

// ─────────────────────────────────────────────────────────────────────────────
// _SectionAccent  (coloured left bar)
// ─────────────────────────────────────────────────────────────────────────────

class _SectionAccent extends StatelessWidget {
  final Color color;
  const _SectionAccent({required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: 4,
        height: 18,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _GoalCard
// ─────────────────────────────────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  final int booksRead;
  final int goal;
  final VoidCallback onEdit;
  const _GoalCard(
      {required this.booksRead, required this.goal, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = goal > 0 ? (booksRead / goal).clamp(0.0, 1.0) : 0.0;
    final percent = (progress * 100).round();

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF4A3538) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.secondaryContainer),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Label row
            Row(
              children: [
                Icon(Icons.emoji_events_rounded,
                    size: 13, color: colorScheme.primary),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Meta anual',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(Icons.edit_rounded,
                    size: 11, color: colorScheme.primary.withOpacity(0.45)),
              ],
            ),
            const SizedBox(height: 6),
            // Value
            RichText(
              text: TextSpan(
                text: '$booksRead',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                children: [
                  TextSpan(
                    text: ' / $goal',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: colorScheme.primary.withOpacity(0.12),
                valueColor:
                    AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              percent == 100 ? '¡Meta cumplida! 🎉' : '$percent% completado',
              style: textTheme.labelSmall?.copyWith(
                color: percent == 100
                    ? const Color(0xFF7BAE8E)
                    : colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StreakCard
// ─────────────────────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  final int streak;
  final List<bool> weekActivity;
  const _StreakCard({required this.streak, required this.weekActivity});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const streakColor = Color(0xFFE8A87C);
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF4A3538) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.secondaryContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded,
                  size: 13, color: streakColor),
              const SizedBox(width: 5),
              Text(
                'Racha',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Value
          RichText(
            text: TextSpan(
              text: '$streak',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: streakColor,
              ),
              children: [
                TextSpan(
                  text: ' días',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Week dots
          Wrap(
            spacing: 4,
            children: List.generate(7, (i) {
              final active = i < weekActivity.length && weekActivity[i];
              return Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: active ? streakColor : streakColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  days[i],
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                    color: active
                        ? Colors.white
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HeroReadingCard  (the primary in-progress item)
// ─────────────────────────────────────────────────────────────────────────────

class _HeroReadingCard extends StatelessWidget {
  final _ReadingItem item;
  final VoidCallback onTap;
  const _HeroReadingCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _typeColor(item.type);
    final icon = _typeIcon(item.type);
    final label = _typeLabel(item.type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF4A3538) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            _Cover(
              coverUrl: item.coverUrl,
              color: color,
              icon: icon,
              ownership: item.ownership,
              width: 82,
              height: 118,
            ),
            const SizedBox(width: 14),
            // Body
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type eyebrow
                  Row(
                    children: [
                      Icon(icon, size: 11, color: color),
                      const SizedBox(width: 4),
                      Text(
                        label.toUpperCase(),
                        style: textTheme.labelSmall?.copyWith(
                          color: color,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Title
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: item.progress,
                      minHeight: 5,
                      backgroundColor: color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Progress labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.progressLabel,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        item.progressPercent,
                        style: textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // CTA button
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continuar leyendo',
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 13, color: colorScheme.onPrimary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _InProgressCarousel  (remaining items with chip filter)
// ─────────────────────────────────────────────────────────────────────────────

class _InProgressCarousel extends StatefulWidget {
  final List<_ReadingItem> items;
  final void Function(_ReadingItem) onTap;
  const _InProgressCarousel({required this.items, required this.onTap});

  @override
  State<_InProgressCarousel> createState() => _InProgressCarouselState();
}

class _InProgressCarouselState extends State<_InProgressCarousel> {
  _ContentType? _filter;

  List<_ReadingItem> get _filtered => _filter == null
      ? widget.items
      : widget.items.where((i) => i.type == _filter).toList();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final filtered = _filtered;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF4A3538) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.secondaryContainer),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Chip row ─────────────────────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  _Chip(
                    label: 'Todo',
                    active: _filter == null,
                    color: colorScheme.primary,
                    onTap: () => setState(() => _filter = null),
                  ),
                  const SizedBox(width: 6),
                  _Chip(
                    label: 'Libros',
                    active: _filter == _ContentType.book,
                    color: _typeColor(_ContentType.book),
                    onTap: () => setState(() => _filter = _ContentType.book),
                  ),
                  const SizedBox(width: 6),
                  _Chip(
                    label: 'Manga',
                    active: _filter == _ContentType.manga,
                    color: _typeColor(_ContentType.manga),
                    onTap: () => setState(() => _filter = _ContentType.manga),
                  ),
                  const SizedBox(width: 6),
                  _Chip(
                    label: 'Fanfics',
                    active: _filter == _ContentType.fanfic,
                    color: _typeColor(_ContentType.fanfic),
                    onTap: () => setState(() => _filter = _ContentType.fanfic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Carousel or empty message ─────────────────────────────────────
            if (filtered.isEmpty)
              SizedBox(
                height: 220,
                child: Center(
                  child: Text(
                    l10n.nothingReading,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 225,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _CarouselCard(
                      item: filtered[i],
                      onTap: () => widget.onTap(filtered[i]),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _Chip
// ─────────────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _Chip(
      {required this.label,
      required this.active,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? color : color.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: active ? Colors.white : color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CarouselCard  (compact card inside the horizontal list)
// ─────────────────────────────────────────────────────────────────────────────

class _CarouselCard extends StatelessWidget {
  final _ReadingItem item;
  final VoidCallback onTap;
  const _CarouselCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = _typeColor(item.type);
    final icon = _typeIcon(item.type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover with % badge
            Stack(
              children: [
                _Cover(
                  coverUrl: item.coverUrl,
                  color: color,
                  icon: icon,
                  ownership: item.ownership,
                  width: 120,
                  height: 160,
                ),
                if (item.progressPercent.isNotEmpty)
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.progressPercent,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            // Thin progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: item.progress,
                  minHeight: 3,
                  backgroundColor: color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item.progressLabel,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _Cover  (shared cover widget with ownership badge)
// ─────────────────────────────────────────────────────────────────────────────

class _Cover extends StatelessWidget {
  final String? coverUrl;
  final Color color;
  final IconData icon;
  final String? ownership;
  final double width;
  final double height;

  const _Cover({
    required this.coverUrl,
    required this.color,
    required this.icon,
    required this.width,
    required this.height,
    this.ownership,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: width,
            height: height,
            child: coverUrl != null && coverUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: coverUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      color: color.withOpacity(0.12),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: color,
                        ),
                      ),
                    ),
                    errorWidget: (_, _, _) =>
                        _CoverFallback(color: color, icon: icon),
                  )
                : _CoverFallback(color: color, icon: icon),
          ),
        ),
        if (ownership != null)
          Positioned(
            top: 4,
            left: 4,
            child: OwnershipBadge(ownership: ownership!),
          ),
      ],
    );
  }
}

class _CoverFallback extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _CoverFallback({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        color: color.withOpacity(0.1),
        child: Center(
          child: Icon(icon, size: 30, color: color.withOpacity(0.5)),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// EditReadingGoalDialog  (placeholder – replace with your real implementation)
// ─────────────────────────────────────────────────────────────────────────────

class EditReadingGoalDialog extends StatefulWidget {
  final int currentGoal;
  const EditReadingGoalDialog({super.key, required this.currentGoal});

  @override
  State<EditReadingGoalDialog> createState() => _EditReadingGoalDialogState();
}

class _EditReadingGoalDialogState extends State<EditReadingGoalDialog> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.currentGoal;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: const Text('Meta de lectura anual'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Libros que quieres leer este año', style: textTheme.bodySmall),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _value > 1 ? () => setState(() => _value--) : null,
              ),
              Text('$_value',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  )),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => setState(() => _value++),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_value),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}