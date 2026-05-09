import 'package:between_pages/models/journal/book_journal_response_dto.dart';
import 'package:between_pages/models/journal/fanfic_journal_response_dto.dart';
import 'package:between_pages/models/journal/manga_journal_response_dto.dart';
import 'package:between_pages/providers/journal/book_journal_provider.dart';
import 'package:between_pages/providers/journal/fanfic_journal_provider.dart';
import 'package:between_pages/providers/journal/manga_journal_provider.dart';
import 'package:between_pages/screens/detail/ownership_badge.dart';
import 'package:between_pages/providers/gamification_provider.dart';
import 'package:between_pages/widgets/rating/reading_goal_card.dart';
import 'package:between_pages/widgets/rating/reading_streak_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:between_pages/repositories/journal_status_extensions.dart';


class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '🌙 Buenas noches';
    if (hour < 12) return '☀️ Buenos días';
    if (hour < 19) return '📖 Buenas tardes';
    return '🌙 Buenas noches';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final booksAsync = ref.watch(bookJournalProvider);
    final mangasAsync = ref.watch(mangaJournalProvider);
    final fanficsAsync = ref.watch(fanficJournalProvider);

    final gamificationAsync = ref.watch(gamificationProvider);
    final gamification = gamificationAsync.valueOrNull;
    final goal = gamification?.annualGoal ?? 12;
    final currentStreak = gamification?.currentStreak ?? 0;
    final weekActivity = gamification?.weekActivity ?? List.filled(7, false);

    // Libros terminados para la meta anual
    final finishedBooks = booksAsync.whenOrNull(
          data: (books) => books.where((b) => b.status == 'FINISHED').length,
        ) ??
        0;

    // Conteo total de items en lectura para el badge del AppBar
    final readingBooksCount = booksAsync.whenOrNull(
          data: (books) => books.where((b) => b.status == 'READING').length,
        ) ??
        0;
    final readingMangasCount = mangasAsync.whenOrNull(
          data: (ms) => ms.where((m) => m.status == 'READING').length,
        ) ??
        0;
    final readingFanficsCount = fanficsAsync.whenOrNull(
          data: (fs) => fs.where((f) => f.status == 'READING').length,
        ) ??
        0;

    final totalReading = readingBooksCount + readingMangasCount + readingFanficsCount;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresca todos los datos al deslizar hacia abajo
          ref.invalidate(bookJournalProvider);
          ref.invalidate(mangaJournalProvider);
          ref.invalidate(fanficJournalProvider);
          ref.invalidate(gamificationProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Necesario para que funcione el RefreshIndicator
          slivers: [
            // ─── AppBar con saludo ──────────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: colorScheme.surface,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Between Pages',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFA87C80),
                    ),
                  ),
                ],
              ),
              actions: [
                if (totalReading > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA87C80).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFA87C80).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_stories,
                              size: 14, color: Color(0xFFA87C80)),
                          const SizedBox(width: 4),
                          Text(
                            'Leyendo $totalReading',
                            style: textTheme.labelSmall?.copyWith(
                              color: const Color(0xFFA87C80),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
  
            // ─── Meta anual + Racha ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    ReadingGoalCard(
                      booksRead: finishedBooks,
                      goal: goal,
                      onEditGoal: () async {
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
                    const SizedBox(height: 12),
                    ReadingStreakCard(
                      streak: currentStreak,
                      weekActivity: weekActivity,
                    ),
                  ],
                ),
              ),
            ),
  
            // ─── Encabezado sección "En progreso" ──────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA87C80),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'En progreso',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
  
            // ─── Cards de contenido en progreso ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _ProgressCard<BookJournalResponseDto>(
                      title: 'Libros',
                      icon: Icons.book_rounded,
                      color: const Color(0xFF7F8C95),
                      asyncValue: booksAsync,
                      onTap: (item) async {
                        final route = item.status.isReading
                            ? '/journal/book/progress'
                            : '/journal/book/edit';
                        // Esperamos a que vuelvas de la pantalla de progreso
                        await context.push(route, extra: item);
                        // Justo al volver, forzamos que se recargue con los datos nuevos
                        ref.invalidate(bookJournalProvider);
                        ref.invalidate(gamificationProvider);
                      },
                      getCoverUrl: (item) => item.book.coverUrl,
                    getTitle: (item) => item.book.title,
                    getOwnership: (item) => item.ownership,
                    getProgress: (item) {
                      final pages = item.book.pageCount ?? 1;
                      final cur = item.currentPage ?? 0;
                      return (cur / (pages > 0 ? pages : 1)).clamp(0.0, 1.0);
                    },
                    getProgressText: (item) => 'Pág. ${item.currentPage ?? 0}',
                  ),
                  const SizedBox(height: 12),
                  _ProgressCard<MangaJournalResponseDTO>(
                    title: 'Manga',
                    icon: Icons.menu_book_rounded,
                    color: const Color(0xFFE8A87C),
                    asyncValue: mangasAsync,
                    onTap: (item) async {
                        await context.push('/journal/manga/edit', extra: item);
                        ref.invalidate(mangaJournalProvider);
                        ref.invalidate(gamificationProvider);
                    },
                    getCoverUrl: (item) => item.manga?.coverUrl,
                    getTitle: (item) => item.manga?.title ?? 'Sin título',
                    getOwnership: (item) => item.ownership,
                    getProgress: (item) {
                      final chaps = item.manga?.totalChapters ?? 1;
                      final cur = item.currentChapter ?? 0;
                      return (cur / (chaps > 0 ? chaps : 1)).clamp(0.0, 1.0);
                    },
                    getProgressText: (item) =>
                        'Cap. ${item.currentChapter ?? 0}',
                  ),
                  const SizedBox(height: 12),
                  _ProgressCard<FanficJournalResponseDTO>(
                    title: 'Fanfics',
                    icon: Icons.favorite_rounded,
                    color: const Color(0xFFD4A0A4),
                    asyncValue: fanficsAsync,
                    onTap: (item) async {
                        await context.push('/journal/fanfic/edit', extra: item);
                        ref.invalidate(fanficJournalProvider);
                        ref.invalidate(gamificationProvider);
                    },
                    getCoverUrl: (item) => item.fanfic.coverUrl,
                    getTitle: (item) => item.fanfic.title ?? 'Sin título',
                    getOwnership: (_) => null,
                    getProgress: (item) {
                      final chaps = item.fanfic.totalChapters ?? 1;
                      final cur = item.currentChapter ?? 0;
                      return (cur / (chaps > 0 ? chaps : 1)).clamp(0.0, 1.0);
                    },
                    getProgressText: (item) =>
                        'Cap. ${item.currentChapter ?? 0}',
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

// ─── Card de progreso por tipo ────────────────────────────────────────────────

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
    this.getOwnership,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF3D2D30)
            : const Color(0xFFFDF5F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 14, color: color),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
          ),
          // Contenido
          Expanded(
            child: asyncValue.when(
              data: (items) {
                final reading = items.where((item) {
                  if (item is BookJournalResponseDto) {
                    return item.status == 'READING';
                  } else if (item is MangaJournalResponseDTO) {
                    return item.status == 'READING';
                  } else if (item is FanficJournalResponseDTO) {
                    return item.status == 'READING';
                  }
                  return true;
                }).toList();

                if (reading.isEmpty) {
                  return _EmptyState(icon: icon, color: color);
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
                    final ownership =
                        getOwnership != null ? getOwnership!(item) : null;

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
                                      child: coverUrl != null &&
                                              coverUrl.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: coverUrl,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Container(
                                                color: colorScheme
                                                    .surfaceContainerHighest,
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                color: colorScheme
                                                    .surfaceContainerHighest,
                                                child: Icon(icon),
                                              ),
                                            )
                                          : Container(
                                              color:
                                                  color.withValues(alpha: 0.1),
                                              child: Center(
                                                child: Icon(
                                                  icon,
                                                  size: 28,
                                                  color: color.withValues(
                                                      alpha: 0.5),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  if (ownership != null)
                                    Positioned(
                                      top: 4,
                                      left: 4,
                                      child: OwnershipBadge(
                                          ownership: ownership),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor:
                                    color.withValues(alpha: 0.15),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(color),
                                minHeight: 3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              itemTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              progressText,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 9,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (error, stack) => Center(
                child: Icon(Icons.error_outline,
                    color: colorScheme.error, size: 24),
              ),
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

  const _EmptyState({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: color.withValues(alpha: 0.3)),
          const SizedBox(height: 6),
          Text(
            'Nada leyendo',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }
}