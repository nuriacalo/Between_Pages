import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/auth/application/repositories/auth_repository.dart';
import 'package:between_pages/features/journal/application/providers/reading_stats_provider.dart';
import 'package:between_pages/features/catalog/presentation/pages/book_edit_page.dart';
import 'package:between_pages/features/catalog/application/repositories/book_search_repository.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/domain/records/book_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/responses/book_journal_response_dto.dart';
import 'package:between_pages/features/journal/presentation/pages/journal_item_edit_page.dart';import 'package:between_pages/features/journal/domain/utils/journal_status_helper.dart';
import 'package:between_pages/features/notes/presentation/widget/second_brain_tab.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BookReadingProgressPage extends ConsumerStatefulWidget {
  final BookJournalResponseDto journal;

  const BookReadingProgressPage({super.key, required this.journal});

  @override
  ConsumerState<BookReadingProgressPage> createState() =>
      _BookReadingProgressPageState();
}

class _BookReadingProgressPageState
    extends ConsumerState<BookReadingProgressPage> {
  bool _isSaving = false;
  int? _currentPageLocal;
  int? _totalPagesLocal;

  BookJournalResponseDto get _journal => widget.journal;
  BookResponseDTO get _book => _journal.book;

  int? get _totalPages => _totalPagesLocal ?? _book.pageCount;
  int get _currentPage => _currentPageLocal ?? _journal.currentPage ?? 0;

  Future<void> _updatePage(int newPage) async {
    if (_isSaving) return;

    final previousPage = _currentPageLocal;
    setState(() {
      _isSaving = true;
      _currentPageLocal = newPage;
    });

    try {
      final auth = ref.read(authRepositoryProvider);
      final repo = ref.read(bookJournalRepositoryProvider);
      final user = await auth.getUserProfile();

      final dto = BookJournalRecordDTO(
        userId: user.idUser,
        bookId: _book.idBook,
        googleBooksId: _book.googleBooksId != null && _book.googleBooksId!.isNotEmpty ? _book.googleBooksId : null,
        status: JournalStatusHelper.mapStatusToDb(_journal.status),
        currentPage: newPage,
        rating: _journal.rating,
        tearDrops: _journal.tearDrops,
        spiceFlames: _journal.spiceFlames,
        readingFormat: _journal.readingFormat,
        emotions: _journal.emotions,
        favoriteQuotes: _journal.favoriteQuotes,
        personalNotes: _journal.personalNotes,
        startDate: _journal.startDate,
        endDate: _journal.endDate,
        ownership: _journal.ownership,
      );

      await repo.saveRaw(dto.toJson());

      ref.invalidate(journalProvider(JournalType.book));
      ref.invalidate(journalEntryProvider((JournalType.book, _book.idBook ?? 0)));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Progreso actualizado'),
              ],
            ),
            backgroundColor: Color(0xFF7BAE8E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _currentPageLocal = previousPage);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveTotalPages(int totalPages) async {
    final previousTotal = _totalPagesLocal;
    setState(() {
      _isSaving = true;
      _totalPagesLocal = totalPages;
    });

    try {
      final repo = ref.read(bookSearchRepositoryProvider);
      
      final bookToSave = BookResponseDTO(
        idBook: _book.idBook,
        googleBooksId: _book.googleBooksId,
        title: _book.title,
        author: _book.author,
        pageCount: totalPages,
        coverUrl: _book.coverUrl,
        isbn: _book.isbn,
        publisher: _book.publisher,
        publishYear: _book.publishYear,
        description: _book.description,
        genres: _book.genres,
        bookType: _book.bookType,
      );

      await repo.saveOrUpdateBook(bookToSave);
      
      ref.invalidate(journalProvider(JournalType.book));
      ref.invalidate(journalEntryProvider((JournalType.book, _book.idBook ?? 0)));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Total de páginas guardado'),
              ],
            ),
            backgroundColor: Color(0xFF7BAE8E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
        _showUpdatePageSheet(knownTotal: totalPages);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _totalPagesLocal = previousTotal);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar páginas: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _promptForTotalPages() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Falta información'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Para hacer un seguimiento adecuado de tu lectura, '
                'necesitamos saber cuántas páginas tiene este libro en total.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Total de páginas',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.auto_stories),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final pages = int.tryParse(controller.text);
                if (pages != null && pages > 0) {
                  Navigator.pop(context);
                  _saveTotalPages(pages);
                }
              },
              child: const Text('Guardar y continuar'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdatePageSheet({int? knownTotal}) {
    final total = knownTotal ?? _totalPages;
    
    if (total == null || total <= 0) {
      _promptForTotalPages();
      return;
    }

    final controller = TextEditingController(text: _currentPage.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Actualizar progreso',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _book.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Página actual (de $total)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF3D2D30)
                          : const Color(0xFFFDF5F2),
                      prefixIcon: const Icon(Icons.menu_book_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isSaving
                          ? null
                          : () {
                              final val = int.tryParse(controller.text);
                              if (val != null && val >= 0) {
                                Navigator.pop(context);
                                _updatePage(val);
                              }
                            },
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: const Text('Guardar progreso'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _goToEditJournal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JournalItemEditPage(journal: _journal, type: JournalType.book)),
    );
  }

  void _goToEditBookDetails() async {
    final result = await Navigator.push<BookResponseDTO>(
      context,
      MaterialPageRoute(
        builder: (_) => BookEditPage(book: _book),
      ),
    );

    if (result != null && mounted) {
      ref.invalidate(journalEntryProvider((JournalType.book, _book.idBook ?? 0)));
      ref.invalidate(journalProvider(JournalType.book));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = const Color(0xFFA87C80);

    final updatedJournal = ref.watch(journalEntryProvider((JournalType.book, _book.idBook ?? 0)));
    final journal = (updatedJournal as BookJournalResponseDto?) ?? _journal;
    final book = journal.book;

    final currentPage = _currentPageLocal ?? journal.currentPage ?? 0;
    final totalPages = _totalPagesLocal ?? book.pageCount;
    final progress = ((totalPages ?? 0) > 0)
        ? (currentPage / totalPages!).clamp(0.0, 1.0) : 0.0;

   return DefaultTabController(
  length: 3,
  child: Scaffold(
    body: NestedScrollView(
      headerSliverBuilder: (context, innerScrolled) => [
        SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: accent,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    book.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: _buildHeader(accent, book.coverUrl),
                ),
                bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.white,
            isScrollable: true,
            tabs: [
              Tab(text: 'Progreso'),
              Tab(text: 'Segundo Cerebro'),
              Tab(text: 'Editar'),
            ],
          ),
        ),
      ],
      body: TabBarView(
        children: [
          _buildProgressTab(accent, currentPage, totalPages, progress, journal, colorScheme, textTheme),
          SecondBrainTab(itemType: 'BOOK', itemId: _book.idBook ?? 0),
          JournalItemEditPage(journal: journal, type: JournalType.book, isStandalone: false),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildProgressTab(Color accent, int currentPage, int? totalPages, double progress, BookJournalResponseDto journal, ColorScheme colorScheme, TextTheme textTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildProgressIndicator(accent, currentPage, totalPages, progress),
          const SizedBox(height: 24),
          _buildStatsGrid(colorScheme, textTheme, journal, currentPage, totalPages),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _showUpdatePageSheet,
              icon: const Icon(Icons.edit_note),
              label: const Text('Actualizar página'),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                context.push('/journal/book/session', extra: _journal);
              },
              icon: const Icon(Icons.timer_outlined),
              label: const Text('Iniciar sesión de lectura'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _goToEditJournal,
              icon: const Icon(Icons.settings),
              label: const Text('Editar journal completo'),
              style: OutlinedButton.styleFrom(
                foregroundColor: accent,
                side: BorderSide(color: accent.withValues(alpha:0.4)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color accent, String? coverUrl) {

    return Container(
      color: accent,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 40, bottom: 60),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 120,
                  height: 180,
                  child: coverUrl != null && coverUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: coverUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.white.withValues(alpha:0.1),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.white.withValues(alpha:0.1),
                            child: const Icon(
                              Icons.book,
                              color: Colors.white54,
                              size: 40,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.white.withValues(alpha:0.1),
                          child: const Icon(
                            Icons.book,
                            color: Colors.white54,
                            size: 40,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(Color accent, int currentPage, int? totalPages, double progress) {
    final total = totalPages;
    final percentage = (progress * 100).toStringAsFixed(1);

    return Column(
      children: [
        SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: 1,
                strokeWidth: 14,
                backgroundColor: accent.withValues(alpha:0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  accent.withValues(alpha:0.1),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return CircularProgressIndicator(
                    value: value,
                    strokeWidth: 14,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                    strokeCap: StrokeCap.round,
                  );
                },
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percentage%',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: accent,
                          ),
                    ),
                    if (total != null && total > 0)
                      Text(
                        '$currentPage / $total',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      )
                    else
                      Text(
                        'Pág. $currentPage',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(ColorScheme colorScheme, TextTheme textTheme, BookJournalResponseDto journal, int currentPage, int? totalPages) {
    int? days;
    if (journal.startDate != null && journal.startDate!.isNotEmpty) {
      try {
        days = DateTime.now().difference(DateTime.parse(journal.startDate!)).inDays + 1;
      } catch (_) {}
    }
    final total = totalPages;
    final remaining = total != null ? (total - currentPage).clamp(0, total) : null;

    return Consumer(
      builder: (context, ref, child) {
        final remainingForStats = remaining ?? 0;
        final statsParams = ReadingStatsParams(
          bookId: journal.book.idBook,
          remainingPages: remainingForStats,
        );
        final statsAsync = ref.watch(itemReadingStatsProvider(statsParams));

        final stats = <_StatItem>[
          if (days != null)
            _StatItem(
              icon: Icons.calendar_today_outlined,
              label: 'Días leyendo',
              value: '$days',
            ),
          if (journal.startDate != null && journal.startDate!.isNotEmpty)
            _StatItem(
              icon: Icons.play_circle_outline,
              label: 'Inicio',
              value: _formatDateShort(journal.startDate!),
            ),
          _StatItem(
            icon: Icons.menu_book,
            label: 'Págs. leídas',
            value: '$currentPage',
          ),
          if (remaining != null)
            _StatItem(
              icon: Icons.auto_stories,
              label: 'Págs. restantes',
              value: '$remaining',
            ),
        ];

        final statsData = statsAsync.value;
        final speed = statsData?['speedPagesPerHour'] as double?;
        if (speed != null && speed > 0 && speed != 30.0) {
          stats.add(
            _StatItem(
              icon: Icons.speed_rounded,
              label: 'Velocidad',
              value: '${speed.toStringAsFixed(1)} p/h',
            ),
          );

          final remainingSecs =
              statsData?['estimatedTimeRemainingSeconds'] as int?;
          if (remainingSecs != null && remainingSecs > 0) {
            final h = remainingSecs ~/ 3600;
            final m = (remainingSecs % 3600) ~/ 60;
            stats.add(
              _StatItem(
                icon: Icons.timer_outlined,
                label: 'Tiempo est.',
                value: h > 0 ? '${h}h ${m}m' : '${m}m',
              ),
            );
          }
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.6,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _StatCard(stat: stat, accent: const Color(0xFFA87C80));
          },
        );
      },
    );
  }

  String _formatDateShort(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _StatCard extends StatelessWidget {
  final _StatItem stat;
  final Color accent;

  const _StatCard({required this.stat, required this.accent});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3D2D30) : const Color(0xFFFDF5F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha:0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(stat.icon, size: 20, color: accent),
          const SizedBox(height: 8),
          Text(
            stat.value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}