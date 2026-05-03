import 'package:between_pages/models/catalog/book_response_dto.dart';
import 'package:between_pages/models/journal/book_journal_record_dto.dart';
import 'package:between_pages/models/journal/book_journal_response_dto.dart';
import 'package:between_pages/providers/journal/book_journal_provider.dart';
import 'package:between_pages/repositories/auth_repository.dart';
import 'package:between_pages/providers/journal/reading_stats_provider.dart';
import 'package:between_pages/repositories/book_journal_repository.dart';
import 'package:between_pages/screens/journal/book_journal_edit_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Página de progreso de lectura de un libro.
/// Muestra stats, progreso circular y permite actualizar la página actual.
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

  BookJournalResponseDto get _journal => widget.journal;
  BookResponseDTO get _book => _journal.book;

  int? get _totalPages => _book.pageCount;
  int get _currentPage => _journal.currentPage ?? 0;

  double get _progress {
    final total = _totalPages;
    if (total == null || total <= 0) return 0.0;
    return (_currentPage / total).clamp(0.0, 1.0);
  }

  int? get _daysReading {
    final start = _journal.startDate;
    if (start == null || start.isEmpty) return null;
    try {
      final startDate = DateTime.parse(start);
      return DateTime.now().difference(startDate).inDays + 1;
    } catch (_) {
      return null;
    }
  }

  int? get _pagesRemaining {
    final total = _totalPages;
    if (total == null) return null;
    return (total - _currentPage).clamp(0, total);
  }

  Future<void> _updatePage(int newPage) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final auth = ref.read(authRepositoryProvider);
      final repo = ref.read(bookJournalRepositoryProvider);
      final user = await auth.getUserProfile();

      final dto = BookJournalRecordDTO(
        userId: user.idUser,
        bookId: _book.idBook > 0 ? _book.idBook : null,
        googleBooksId: _book.googleBooksId.isNotEmpty ? _book.googleBooksId : null,
        title: _book.title.isNotEmpty ? _book.title : null,
        author: _book.author.isNotEmpty ? _book.author : null,
        isbn: _book.isbn,
        publisher: _book.publisher,
        description: _book.description,
        coverUrl: _book.coverUrl,
        genre: _book.genre,
        publicationYear: _book.publishYear,
        status: _journal.status,
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

      await repo.saveOrUpdate(dto);

      // Refrescar providers
      ref.invalidate(bookJournalProvider);
      ref.invalidate(bookJournalEntryProvider(_book.idBook));

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

  void _showUpdatePageSheet() {
    final total = _totalPages;
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
                      labelText: total != null
                          ? 'Página actual (de $total)'
                          : 'Página actual',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness ==
                              Brightness.dark
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
      MaterialPageRoute(
        builder: (_) => BookJournalEditPage(journal: _journal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = const Color(0xFFA87C80);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── AppBar colapsable con portada ────────────────────────────
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: accent,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _book.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: _buildHeader(accent),
            ),
          ),

          // ─── Contenido principal ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Indicador circular de progreso
                  _buildProgressIndicator(accent),
                  const SizedBox(height: 24),

                  // Stats grid
                  _buildStatsGrid(colorScheme, textTheme),
                  const SizedBox(height: 32),

                  // Botón actualizar progreso
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

                // Botón Iniciar cronómetro de lectura (Módulo 1)
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

                  // Botón editar journal completo
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _goToEditJournal,
                      icon: const Icon(Icons.settings),
                      label: const Text('Editar journal completo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accent,
                        side: BorderSide(color: accent.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color accent) {
    final coverUrl = _book.coverUrl;

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
                    color: Colors.black.withValues(alpha: 0.3),
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
                          placeholder: (_, __) => Container(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.white.withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.book,
                              color: Colors.white54,
                              size: 40,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.white.withValues(alpha: 0.1),
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

  Widget _buildProgressIndicator(Color accent) {
    final total = _totalPages;
    final progress = _progress;
    // Módulo 1: Precisión matemática con 1 decimal
    final percentage = (progress * 100).toStringAsFixed(1);

    return Column(
      children: [
        SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Fondo del círculo
              CircularProgressIndicator(
                value: 1,
                strokeWidth: 14,
                backgroundColor: accent.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  accent.withValues(alpha: 0.1),
                ),
              ),
              // Progreso animado
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
              // Texto central
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percentage%',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: accent,
                          ),
                    ),
                    if (total != null)
                      Text(
                        '$_currentPage / $total',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      )
                    else
                      Text(
                        'Pág. $_currentPage',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
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

  Widget _buildStatsGrid(ColorScheme colorScheme, TextTheme textTheme) {
    final days = _daysReading;
    final remaining = _pagesRemaining;
    final total = _totalPages;

    return Consumer(
      builder: (context, ref, child) {
        final statsAsync = ref.watch(itemReadingStatsProvider({
          'bookId': _book.idBook,
          'remainingPages': remaining ?? 0,
        }));

        final stats = <_StatItem>[
          if (days != null)
            _StatItem(
              icon: Icons.calendar_today_outlined,
              label: 'Días leyendo',
              value: '$days',
            ),
          if (_journal.startDate != null && _journal.startDate!.isNotEmpty)
            _StatItem(
              icon: Icons.play_circle_outline,
              label: 'Inicio',
              value: _formatDateShort(_journal.startDate!),
            ),
          _StatItem(
            icon: Icons.menu_book,
            label: 'Págs. leídas',
            value: '$_currentPage',
          ),
          if (remaining != null)
            _StatItem(
              icon: Icons.auto_stories,
              label: 'Págs. restantes',
              value: '$remaining',
            ),
          if (total != null)
            _StatItem(
              icon: Icons.format_align_justify,
              label: 'Total páginas',
              value: '$total',
            ),
        ];

        final statsData = statsAsync.value;
        if (statsData != null && (statsData['speedPagesPerHour'] as double) > 0) {
          final speed = statsData['speedPagesPerHour'] as double;
          final remainingSecs = statsData['estimatedTimeRemainingSeconds'] as int;

          stats.add(_StatItem(
            icon: Icons.speed_rounded,
            label: 'Velocidad',
            value: '${speed.toStringAsFixed(1)} p/h',
          ));

          if (remainingSecs > 0) {
            final h = remainingSecs ~/ 3600;
            final m = (remainingSecs % 3600) ~/ 60;
            stats.add(_StatItem(
              icon: Icons.timer_outlined,
              label: 'Tiempo est.',
              value: h > 0 ? '${h}h ${m}m' : '${m}m',
            ));
          }
        }

    // Si no hay pageCount, mostrar solo páginas leídas y quizás algunos defaults
    if (stats.length < 2) {
      stats.add(
        _StatItem(
          icon: Icons.info_outline,
          label: 'Total páginas',
          value: 'Desconocido',
        ),
      );
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

// ─── Modelo y card para stats ─────────────────────────────────────────────────

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
        border: Border.all(
          color: accent.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(stat.icon, size: 20, color: accent),
          const SizedBox(height: 8),
          Text(
            stat.value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
