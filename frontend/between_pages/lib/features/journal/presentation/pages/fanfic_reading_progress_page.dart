import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/auth/application/repositories/auth_repository.dart';
import 'package:between_pages/features/catalog/application/repositories/fanfic_search_repository.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/catalog/presentation/pages/fanfic_edit_page.dart';
import 'package:between_pages/features/catalog/presentation/pages/item_reading_stats_provider.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/domain/records/fanfic_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/responses/fanfic_journal_response_dto.dart';
import 'package:between_pages/features/journal/presentation/pages/journal_item_edit_page.dart';
import 'package:between_pages/features/journal/domain/utils/journal_status_helper.dart';
import 'package:between_pages/features/profile/application/providers/gamification_provider.dart';
import 'package:between_pages/features/profile/application/repositories/reading_stats_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FanficReadingProgressPage extends ConsumerStatefulWidget {
  final FanficJournalResponseDTO journal;

  const FanficReadingProgressPage({super.key, required this.journal});

  @override
  ConsumerState<FanficReadingProgressPage> createState() => _FanficReadingProgressPageState();
}

class _FanficReadingProgressPageState extends ConsumerState<FanficReadingProgressPage> {
  bool _isSaving = false;
  int? _currentChapterLocal;
  int? _totalChaptersLocal;
  
  FanficJournalResponseDTO get _journal => widget.journal;
  FanfictionResponseDTO get _fanfic => _journal.fanfic;
  
  int? get _totalChapters => _totalChaptersLocal ?? _fanfic.totalChapters;
  int get _currentChapter => _currentChapterLocal ?? _journal.currentChapter ?? 0;

  Future<void> _updateChapter(int newChapter) async {
    if (_isSaving) return;

    final previousChapter = _currentChapterLocal;
    setState(() {
      _isSaving = true;
      _currentChapterLocal = newChapter;
    });

    try {
      final auth = ref.read(authRepositoryProvider);
      final repo = ref.read(fanficJournalRepositoryProvider);
      final user = await auth.getUserProfile();

      final dto = FanficJournalRecordDTO(
        id: _journal.id,
        userId: user.idUser,
        fanficId: _fanfic.idFanfic ?? 0,
        ao3Id: _fanfic.ao3Id,
        status: JournalStatusHelper.mapStatusToDb(_journal.status),
        currentChapter: newChapter,
        rating: _journal.rating,
        tearDrops: _journal.tearDrops,
        spiceFlames: _journal.spiceFlames,
        personalNotes: _journal.personalNotes,
        startDate: _journal.startDate,
        endDate: _journal.endDate,
        rereading: _journal.rereading,
        mainShip: _journal.mainShip,
        secondaryShips: _journal.secondaryShips,
        angstLevel: _journal.angstLevel,
        shipLoyalty: _journal.shipLoyalty,
        canonType: _journal.canonType,
      );

      await repo.saveRaw(dto.toJson());

      try {
        await ref.read(readingStatsRepositoryProvider).recordActivity();
        ref.invalidate(gamificationProvider);
      } catch (e) {
        debugPrint('Error al registrar actividad: $e');
      }

      ref.invalidate(journalProvider(JournalType.fanfic));
      ref.invalidate(journalEntryProvider((JournalType.fanfic, _fanfic.idFanfic ?? 0)));

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
        setState(() => _currentChapterLocal = previousChapter);
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

  Future<void> _saveTotalChapters(int totalChapters) async {
    final previousTotal = _totalChaptersLocal;
    setState(() {
      _isSaving = true;
      _totalChaptersLocal = totalChapters;
    });

    try {
      final repo = ref.read(fanficSearchRepositoryProvider);
      
      final fanficToSave = FanfictionResponseDTO(
        idFanfic: _fanfic.idFanfic,
        ao3Id: _fanfic.ao3Id,
        title: _fanfic.title,
        author: _fanfic.author,
        sourceMaterial: _fanfic.sourceMaterial,
        totalChapters: totalChapters,
        coverUrl: _fanfic.coverUrl,
        description: _fanfic.description,
        publicationStatus: _fanfic.publicationStatus,
        mainShip: _fanfic.mainShip,
        theme: _fanfic.theme,
        tags: _fanfic.tags,
      );

      await repo.saveOrUpdateFanfic(fanficToSave);
      
      ref.invalidate(journalProvider(JournalType.fanfic));
      ref.invalidate(journalEntryProvider((JournalType.fanfic, _fanfic.idFanfic ?? 0)));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Total de capítulos guardado'),
              ],
            ),
            backgroundColor: Color(0xFF7BAE8E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
        _showUpdateChapterSheet(knownTotal: totalChapters);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _totalChaptersLocal = previousTotal);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar capítulos: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _goToEditFanficDetails() async {
    final result = await Navigator.push<FanfictionResponseDTO>(
      context,
      MaterialPageRoute(
        builder: (_) => FanficEditPage(fanfic: _fanfic),
      ),
    );

    if (result != null && mounted) {
      ref.invalidate(journalEntryProvider((JournalType.fanfic, _fanfic.idFanfic ?? 0)));
      ref.invalidate(journalProvider(JournalType.fanfic));
    }
  }

  void _promptForTotalChapters() {
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
                'necesitamos saber cuántos capítulos tiene este fanfic en total.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Total de capítulos',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.bookmark_outline),
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
                final chapters = int.tryParse(controller.text);
                if (chapters != null && chapters > 0) {
                  Navigator.pop(context);
                  _saveTotalChapters(chapters);
                }
              },
              child: const Text('Guardar y continuar'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateChapterSheet({int? knownTotal}) {
    final total = knownTotal ?? _totalChapters;
    
    if (total == null || total <= 0) {
      _promptForTotalChapters();
      return;
    }

    final controller = TextEditingController(text: _currentChapter.toString());

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
                    _fanfic.title ?? 'Sin título',
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
                      labelText: 'Capítulo actual (de $total)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF3D2D30)
                          : const Color(0xFFFDF5F2),
                      prefixIcon: const Icon(Icons.bookmark_outlined),
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
                                _updateChapter(val);
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
      MaterialPageRoute(builder: (_) => JournalItemEditPage(journal: _journal, type: JournalType.fanfic)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = const Color(0xFFD4A0A4);
    
    final updatedJournal = ref.watch(journalEntryProvider((JournalType.fanfic, _fanfic.idFanfic ?? 0)));
    final journal = (updatedJournal as FanficJournalResponseDTO?) ?? _journal;
    final fanfic = journal.fanfic;

    final currentChapter = _currentChapterLocal ?? journal.currentChapter ?? 0;
    final totalChapters = _totalChaptersLocal ?? fanfic.totalChapters;
    final progress = ((totalChapters ?? 0) > 0)
        ? (currentChapter / totalChapters!).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerScrolled) => [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: accent,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                fanfic.title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: _buildHeader(accent, fanfic.coverUrl),
            ),
          ),
        ],
        body: _buildProgressTab(accent, currentChapter, totalChapters, progress, journal, colorScheme, textTheme),
      ),
    );
  }

  Widget _buildProgressTab(Color accent, int currentChapter, int? totalChapters, double progress, FanficJournalResponseDTO journal, ColorScheme colorScheme, TextTheme textTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildProgressIndicator(accent, currentChapter, totalChapters, progress),
          const SizedBox(height: 24),
          _buildStatsGrid(colorScheme, textTheme, journal, currentChapter, totalChapters),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _showUpdateChapterSheet,
              icon: const Icon(Icons.edit_note),
              label: const Text('Actualizar capítulo'),
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
                context.push('/journal/fanfic/session', extra: _journal);
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
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(77), blurRadius: 20, offset: const Offset(0, 8))],
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
                          placeholder: (context, url) => Container(color: Colors.white.withAlpha(26)),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.white.withAlpha(26),
                            child: const Icon(Icons.book, color: Colors.white54, size: 40),
                          ),
                        )
                      : Container(
                          color: Colors.white.withAlpha(26),
                          child: const Icon(Icons.book, color: Colors.white54, size: 40),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(Color accent, int currentChapter, int? totalChapters, double progress) {
    final total = totalChapters;
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
                        '$currentChapter / $total',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      )
                    else
                      Text(
                        'Cap. $currentChapter',
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

  Widget _buildStatsGrid(ColorScheme colorScheme, TextTheme textTheme, FanficJournalResponseDTO journal, int currentChapter, int? totalChapters) {
    int? days;
    if (journal.startDate != null && journal.startDate!.isNotEmpty) {
      try {
        days = DateTime.now().difference(DateTime.parse(journal.startDate!)).inDays + 1;
      } catch (_) {}
    }
    final total = totalChapters;
    final remaining = total != null ? (total - currentChapter).clamp(0, total) : null;

    return Consumer(
      builder: (context, ref, child) {
        final remainingForStats = remaining ?? 0;
        final statsParams = ItemStatsParams(
          itemId: journal.fanfic.idFanfic,
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
            icon: Icons.bookmark_added_outlined,
            label: 'Cap. leídos',
            value: '$currentChapter',
          ),
          if (remaining != null)
            _StatItem(
              icon: Icons.library_books_outlined,
              label: 'Cap. restantes',
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
              value: '${speed.toStringAsFixed(1)} c/h',
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
            return _StatCard(stat: stat, accent: const Color(0xFFD4A0A4));
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