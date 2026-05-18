import 'package:between_pages/core/widgets/empty_state.dart';
import 'package:between_pages/features/catalog/presentation/widgets/ownership_badge.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/journal/domain/base_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/book_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/fanfic_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/domain/manga_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/utils/journal_status_extensions.dart';
import 'package:between_pages/features/profile/application/providers/gamification_provider.dart';
import 'package:between_pages/features/profile/presentation/widgets/reading_goal_card.dart'; // Re-import ReadingGoalCard
import 'package:between_pages/features/profile/presentation/widgets/reading_streak_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:between_pages/l10n/app_localizations.dart';


class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 6) return l10n.greetingNight;
    if (hour < 12) return l10n.greetingMorning;
    if (hour < 19) return l10n.greetingAfternoon;
    return l10n.greetingNight;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final allJournalsAsync = ref.watch(allJournalsProvider);
    final booksAsync = allJournalsAsync.whenData((journals) => journals[JournalType.book] ?? []);
    final mangasAsync = allJournalsAsync.whenData((journals) => journals[JournalType.manga] ?? []);
    final fanficsAsync = allJournalsAsync.whenData((journals) => journals[JournalType.fanfic] ?? []);

    final gamificationAsync = ref.watch(gamificationProvider);
    final gamification = gamificationAsync.valueOrNull;
    final goal = gamification?.annualGoal ?? 12; // Re-add goal
    final currentStreak = gamification?.currentStreak ?? 0;
    final weekActivity = gamification?.weekActivity ?? List.filled(7, false);

    final finishedBooks = booksAsync.whenOrNull(data: (books) => books.where((b) => b.status.isFinished).length) ?? 0; // Re-add finishedBooks
    final readingBooksCount = booksAsync.whenOrNull(data: (books) => books.where((b) => b.status.isReading).length) ?? 0;
    final readingMangasCount = mangasAsync.whenOrNull(data: (ms) => ms.where((m) => m.status.isReading).length) ?? 0;
    final readingFanficsCount = fanficsAsync.whenOrNull(data: (fs) => fs.where((f) => f.status.isReading).length) ?? 0;
    final totalReading = readingBooksCount + readingMangasCount + readingFanficsCount;

    // Check for the global empty state condition
    final allLoaded = !booksAsync.isLoading && !mangasAsync.isLoading && !fanficsAsync.isLoading;
    final allEmpty = (booksAsync.valueOrNull?.isEmpty ?? true) &&
                     (mangasAsync.valueOrNull?.isEmpty ?? true) &&
                     (fanficsAsync.valueOrNull?.isEmpty ?? true);

    if (allLoaded && allEmpty) {
      return EmptyState(
        icon: Icons.shelves,
        title: 'Your library is empty',
        subtitle: 'Add a book, manga, or fanfic to start your journey.',
        actionLabel: 'Find something to read',
        onAction: () => GoRouter.of(context).go('/search'), // Assuming '/search' is your search route
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.refresh(allJournalsProvider.future);
          await ref.refresh(gamificationProvider.future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: colorScheme.surface,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_greeting(l10n), style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  Text('Between Pages', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFFA87C80))),
                ],
              ),
              actions: [
                if (totalReading > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA87C80).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFA87C80).withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_stories, size: 14, color: Color(0xFFA87C80)),
                          const SizedBox(width: 4),
                          Text('${l10n.statusReading} $totalReading', style: textTheme.labelSmall?.copyWith(color: const Color(0xFFA87C80), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    ReadingGoalCard( // Re-add ReadingGoalCard
                      booksRead: finishedBooks,
                      goal: goal,
                      onEditGoal: () async {
                        final newGoal = await showDialog<int>(context: context, builder: (_) => EditReadingGoalDialog(currentGoal: goal));
                        if (newGoal != null) {
                          ref.read(gamificationProvider.notifier).updateGoal(newGoal);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    ReadingStreakCard(streak: currentStreak, weekActivity: weekActivity),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  children: [
                    Container(width: 4, height: 18, decoration: BoxDecoration(color: const Color(0xFFA87C80), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 10),
                    Text(l10n.inProgressTitle, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _ProgressCard<BaseJournalResponseDTO>(
                      title: l10n.tabBooks,
                      icon: Icons.book_rounded,
                      color: const Color(0xFF7F8C95),
                      asyncValue: booksAsync,
                      emptyText: l10n.nothingReading,
                      onTap: (item) async {
                        final journal = item as BookJournalResponseDto;
                        await context.push('/journal/book/progress', extra: journal);
                        ref.invalidate(journalProvider(JournalType.book));
                        ref.invalidate(gamificationProvider);
                      },
                      getCoverUrl: (item) => (item as BookJournalResponseDto).book.coverUrl,
                      getTitle: (item) => (item as BookJournalResponseDto).book.title,
                      getOwnership: (item) => (item as BookJournalResponseDto).ownership,
                      getProgress: (item) {
                        final journal = item as BookJournalResponseDto;
                        final pages = journal.book.pageCount ?? 1;
                        final cur = journal.currentPage ?? 0;
                        return (cur / (pages > 0 ? pages : 1)).clamp(0.0, 1.0);
                      },
                      getProgressText: (item) => 'Pág. ${(item as BookJournalResponseDto).currentPage ?? 0}',
                    ),
                    const SizedBox(height: 12),
                    _ProgressCard<BaseJournalResponseDTO>(
                      title: l10n.tabMangas,
                      icon: Icons.menu_book_rounded,
                      color: const Color(0xFFE8A87C),
                      asyncValue: mangasAsync,
                      emptyText: l10n.nothingReading,
                      onTap: (item) async {
                        final journal = item as MangaJournalResponseDTO;
                        await context.push('/journal/manga/session', extra: journal);
                        ref.invalidate(journalProvider(JournalType.manga));
                        ref.invalidate(gamificationProvider);
                      },
                      getCoverUrl: (item) => (item as MangaJournalResponseDTO).manga?.coverUrl,
                      getTitle: (item) => (item as MangaJournalResponseDTO).manga?.title ?? 'Sin título',
                      getOwnership: (item) => (item as MangaJournalResponseDTO).ownership,
                      getProgress: (item) {
                        final journal = item as MangaJournalResponseDTO;
                        final chaps = journal.manga?.totalChapters ?? 1;
                        final cur = journal.currentChapter ?? 0;
                        return (cur / (chaps > 0 ? chaps : 1)).clamp(0.0, 1.0);
                      },
                      getProgressText: (item) => 'Cap. ${(item as MangaJournalResponseDTO).currentChapter ?? 0}',
                    ),
                    const SizedBox(height: 12),
                    _ProgressCard<BaseJournalResponseDTO>(
                      title: l10n.tabFanfics,
                      icon: Icons.favorite_rounded,
                      color: const Color(0xFFD4A0A4),
                      asyncValue: fanficsAsync,
                      emptyText: l10n.nothingReading,
                      onTap: (item) async {
                        final journal = item as FanficJournalResponseDTO;
                        await context.push('/journal/fanfic/session', extra: journal);
                        ref.invalidate(journalProvider(JournalType.fanfic));
                        ref.invalidate(gamificationProvider);
                      },
                      getCoverUrl: (item) => (item as FanficJournalResponseDTO).fanfic.coverUrl,
                      getTitle: (item) => (item as FanficJournalResponseDTO).fanfic.title ?? 'Sin título',
                      getOwnership: (_) => null,
                      getProgress: (item) {
                        final journal = item as FanficJournalResponseDTO;
                        final chaps = journal.fanfic.totalChapters ?? 1;
                        final cur = journal.currentChapter ?? 0;
                        return (cur / (chaps > 0 ? chaps : 1)).clamp(0.0, 1.0);
                      },
                      getProgressText: (item) => 'Cap. ${(item as FanficJournalResponseDTO).currentChapter ?? 0}',
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard<T> extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final AsyncValue<List<T>> asyncValue;
  final void Function(T) onTap;
  final String? Function(T) getCoverUrl;
  final String Function(T) getTitle;
  final String? Function(T)? getOwnership;
  final double Function(T) getProgress;
  final String Function(T) getProgressText;
  final String emptyText;

  const _ProgressCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.asyncValue,
    required this.onTap,
    required this.getCoverUrl,
    required this.getTitle,
    required this.getProgress,
    required this.getProgressText,
    required this.emptyText,
    this.getOwnership,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3D2D30) : const Color(0xFFFDF5F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, size: 14, color: color),
                ),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
          Expanded(
            child: asyncValue.when(
              data: (items) {
                final reading = items.where((item) {
                  if (item is BookJournalResponseDto) return item.status.isReading;
                  if (item is MangaJournalResponseDTO) return item.status.isReading;
                  if (item is FanficJournalResponseDTO) return item.status.isReading;
                  return true;
                }).toList();

                if (reading.isEmpty) {
                  return _EmptyState(icon: icon, color: color, message: emptyText);
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  itemCount: reading.length,
                  itemBuilder: (context, index) {
                    final item = reading[index];
                    final coverUrl = getCoverUrl(item);
                    final itemTitle = getTitle(item);
                    final progress = getProgress(item);
                    final progressText = getProgressText(item);
                    final ownership = getOwnership != null ? getOwnership!(item) : null;

                    return GestureDetector(
                      onTap: () => onTap(item),
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: 100,
                                      child: coverUrl != null && coverUrl.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: coverUrl,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(color: colorScheme.surfaceContainerHighest),
                                              errorWidget: (context, url, error) => Container(color: colorScheme.surfaceContainerHighest, child: Icon(icon)),
                                            )
                                          : Container(
                                              color: color.withOpacity(0.1),
                                              child: Center(child: Icon(icon, size: 28, color: color.withOpacity(0.5))),
                                            ),
                                    ),
                                  ),
                                  if (ownership != null)
                                    Positioned(top: 4, left: 4, child: OwnershipBadge(ownership: ownership)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(value: progress, backgroundColor: color.withOpacity(0.15), valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 3),
                            ),
                            const SizedBox(height: 3),
                            Text(itemTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
                            Text(progressText, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 9)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              error: (error, stack) => Center(child: Icon(Icons.error_outline, color: colorScheme.error, size: 24)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;

  const _EmptyState({required this.icon, required this.color, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: color.withOpacity(0.3)),
          const SizedBox(height: 6),
          Text(message, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.outline, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

// Placeholder for the dialog to prevent compilation errors.
class EditReadingGoalDialog extends StatelessWidget {
  final int currentGoal;
  const EditReadingGoalDialog({super.key, required this.currentGoal});
  @override
  Widget build(BuildContext context) => const Dialog();
}