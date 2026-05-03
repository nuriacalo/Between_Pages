import 'package:between_pages/models/journal/book_journal_response_dto.dart';
import 'package:between_pages/models/journal/fanfic_journal_response_dto.dart';
import 'package:between_pages/models/journal/manga_journal_response_dto.dart';
import 'package:between_pages/providers/journal/book_journal_provider.dart';
import 'package:between_pages/providers/journal/fanfic_journal_provider.dart';
import 'package:between_pages/providers/journal/manga_journal_provider.dart';
import 'package:between_pages/screens/detail/ownership_badge.dart';
import 'package:between_pages/widgets/rating/reading_goal_card.dart';
import 'package:between_pages/widgets/rating/reading_streak_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Provider temporal para la meta de lectura (persiste en memoria).
/// TODO: Conectar a SharedPreferences o backend.
final readingGoalProvider = StateProvider<int>((ref) => 12);

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final booksAsync = ref.watch(bookJournalProvider);
    final mangasAsync = ref.watch(mangaJournalProvider);
    final fanficsAsync = ref.watch(fanficJournalProvider);
    final goal = ref.watch(readingGoalProvider);

    // Cuenta libros terminados para la meta
    final finishedBooks = booksAsync.whenOrNull(
          data: (books) => books.where((b) => b.status == 'FINISHED').length,
        ) ??
        0;

    // Items en progreso para el hero
    final readingBooks = booksAsync.whenOrNull(
      data: (books) => books.where((b) => b.status == 'READING').toList(),
    );

    final readingMangas = mangasAsync.whenOrNull(
      data: (ms) => ms.where((m) => m.status == 'READING').toList(),
    );

    final readingFanfics = fanficsAsync.whenOrNull(
      data: (fs) => fs.where((f) => f.status == 'READING').toList(),
    );

    final totalReading = (readingBooks?.length ?? 0) +
        (readingMangas?.length ?? 0) +
        (readingFanfics?.length ?? 0);

    // Racha de la semana (dummy - TODO conectar con backend)
    final weekActivity = List.generate(
      7,
      (i) => i < DateTime.now().weekday - 1,
    );
    const currentStreak = 3; // TODO: obtener del backend

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
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

          // ─── Hero: Actualmente leyendo ──────────────────────────────────
          if (readingBooks != null && readingBooks.isNotEmpty)
          SliverToBoxAdapter(
            child: _CurrentlyReadingHero(
              books: readingBooks,
              onTap: (book) =>
                  context.push('/journal/book/progress', extra: book),
            ),
          ),

          // ─── Meta anual + Racha (en fila si caben) ─────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
                        ref.read(readingGoalProvider.notifier).state = newGoal;
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

          // ─── Grid de contenido en progreso ─────────────────────────────
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
                    onTap: (item) {
                      final route = item.status == 'READING'
                          ? '/journal/book/progress'
                          : '/journal/book/edit';
                      context.push(route, extra: item);
                    },
                    getCoverUrl: (item) => item.book.coverUrl,
                    getTitle: (item) => item.book.title,
                    getOwnership: (item) => item.ownership,
                    getProgress: (item) {
                      final pages = item.book.pageCount ?? 1;
                      final cur = item.currentPage ?? 0;
                      return (cur / (pages > 0 ? pages : 1)).clamp(0.0, 1.0);
                    },
                    getProgressText: (item) =>
                        'Pág. ${item.currentPage ?? 0}',
                  ),
                  const SizedBox(height: 12),
                  _ProgressCard<MangaJournalResponseDTO>(
                    title: 'Manga',
                    icon: Icons.menu_book_rounded,
                    color: const Color(0xFFE8A87C),
                    asyncValue: mangasAsync,
                    onTap: (item) =>
                        context.push('/journal/manga/edit', extra: item),
                    getCoverUrl: (item) => item.manga?.coverUrl,
                    getTitle: (item) =>
                        item.manga?.title ?? 'Sin título',
                    getOwnership: (item) => item.ownership,
                    getProgress: (item) {
                      final chaps = item.manga?.totalChapters ?? 1;
                      final cur = item.currentChapter ?? 0;
                      return (cur / (chaps > 0 ? chaps : 1))
                          .clamp(0.0, 1.0);
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
                    onTap: (item) => context.push(
                      '/fanfic/${item.fanfic.idFanfic}',
                      extra: item.fanfic,
                    ),
                    getCoverUrl: (item) => item.fanfic.coverUrl,
                    getTitle: (item) =>
                        item.fanfic.title ?? 'Sin título',
                    getOwnership: (_) => null,
                    getProgress: (item) {
                      final chaps = item.fanfic.totalChapters ?? 1;
                      final cur = item.currentChapter ?? 0;
                      return (cur / (chaps > 0 ? chaps : 1))
                          .clamp(0.0, 1.0);
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
    );
  }
}

// ─── Hero de "Actualmente leyendo" ────────────────────────────────────────────

class _CurrentlyReadingHero extends StatelessWidget {
  final List<BookJournalResponseDto> books;
  final void Function(BookJournalResponseDto) onTap;

  const _CurrentlyReadingHero({
    required this.books,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final featured = books.first;
    final book = featured.book;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = book.pageCount ?? 1;
    final cur = featured.currentPage ?? 0;
    final progress = pages > 0 ? (cur / pages).clamp(0.0, 1.0) : 0.0;
    final coverUrl = book.coverUrl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: () => onTap(featured),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: isDark
                  ? [
                      const Color(0xFF4A3538),
                      const Color(0xFF3D2D30),
                    ]
                  : [
                      const Color(0xFFF5E6E0),
                      const Color(0xFFFDF5F2),
                    ],
            ),
            border: Border.all(
              color: const Color(0xFFA87C80).withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA87C80).withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Portada
              Padding(
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 76,
                    height: double.infinity,
                    child: coverUrl != null && coverUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: coverUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: colorScheme.surfaceContainerHighest,
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.book),
                            ),
                          )
                        : Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.book),
                          ),
                  ),
                ),
              ),

              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA87C80)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Leyendo ahora',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: const Color(0xFFA87C80),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                  ),
                            ),
                          ),
                          if (books.length > 1) ...[
                            const SizedBox(width: 6),
                            Text(
                              '+${books.length - 1} más',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 9,
                                  ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (book.author != null)
                        Text(
                          book.author!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: colorScheme.onSurfaceVariant),
                        ),
                      const Spacer(),
                      // Barra de progreso
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: const Color(0xFFA87C80)
                              .withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFA87C80),
                          ),
                          minHeight: 5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pág. $cur de $pages · ${(progress * 100).toInt()}%',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 10),
                      ),
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
                // Filtra solo los "Leyendo"
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
                                              placeholder: (_, __) =>
                                                  Container(
                                                color: colorScheme
                                                    .surfaceContainerHighest,
                                              ),
                                              errorWidget:
                                                  (_, __, ___) => Container(
                                                color: colorScheme
                                                    .surfaceContainerHighest,
                                                child: Icon(icon),
                                              ),
                                            )
                                          : Container(
                                              color: color.withValues(
                                                  alpha: 0.1),
                                              child: Center(
                                                  child: Icon(icon,
                                                      size: 28,
                                                      color: color
                                                          .withValues(
                                                              alpha: 0.5))),
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
                            // Mini barra de progreso
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
              error: (_, __) => Center(
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