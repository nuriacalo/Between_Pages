import 'package:between_pages/core/theme/app_colors.dart';
import 'package:between_pages/features/auth/application/repositories/auth_repository.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/journal/application/providers/reading_timer_provider.dart';
import 'package:between_pages/features/journal/application/repositories/reading_session_repository.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/domain/manga_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/records/book_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/records/fanfic_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/records/reading_session_record_dto.dart';
import 'package:between_pages/features/journal/domain/responses/book_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/fanfic_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/manga_journal_response_dto.dart';
// FIX: updated import from second_brain_tab.dart → notes_tab.dart
import 'package:between_pages/features/notes/presentation/widget/notes_tab.dart';
import 'package:between_pages/features/profile/application/providers/gamification_provider.dart';
import 'package:between_pages/features/profile/application/repositories/reading_stats_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum SessionMediaType { book, manga, fanfic }

class UniversalSessionData {
  final SessionMediaType mediaType;
  final int              itemId;
  final ReadingItemType  timerItemType;
  final String           title;
  final String?          coverUrl;
  final int              currentProgress;
  final int?             totalProgress;
  final String           progressPrompt;
  final Color            accentColor;
  final dynamic          rawJournal;

  const UniversalSessionData({
    required this.mediaType,
    required this.itemId,
    required this.timerItemType,
    required this.title,
    this.coverUrl,
    required this.currentProgress,
    this.totalProgress,
    required this.progressPrompt,
    required this.accentColor,
    required this.rawJournal,
  });
}

class UniversalSessionPage extends ConsumerStatefulWidget {
  final UniversalSessionData data;
  const UniversalSessionPage({super.key, required this.data});

  @override
  ConsumerState<UniversalSessionPage> createState() =>
      _UniversalSessionPageState();
}

class _UniversalSessionPageState extends ConsumerState<UniversalSessionPage> {
  bool _isSaving = false;

  // ── Helpers ───────────────────────────────────────────────────────────────

  Color get _accent => widget.data.accentColor;

  /// Converts the enum to the string the notes API expects.
  String get _itemTypeString =>
      widget.data.mediaType.name.toUpperCase(); // 'BOOK' | 'MANGA' | 'FANFIC'

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
          '${m.toString().padLeft(2, '0')}:'
          '${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.data.itemId > 0) {
        ref
            .read(readingTimerProvider.notifier)
            .start(widget.data.itemId, widget.data.timerItemType);
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Finish session
  // ─────────────────────────────────────────────────────────────────────────

  void _finishSession() {
    ref.read(readingTimerProvider.notifier).pause();
    final elapsed    = ref.read(readingTimerProvider).elapsedSeconds;
    final controller = TextEditingController(
      text: widget.data.currentProgress.toString(),
    );

    showModalBottomSheet<void>(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 20, 24,
          MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize:       MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width:  40, height: 4,
                decoration: BoxDecoration(
                  color:        Theme.of(sheetCtx).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              '¡Sesión finalizada!',
              style: Theme.of(sheetCtx).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Time summary card
            Container(
              padding:    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color:        _accent.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: _accent.withValues(alpha:0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, color: _accent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Tiempo de lectura: ',
                    style: Theme.of(sheetCtx).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary(sheetCtx),
                    ),
                  ),
                  Text(
                    _formatTime(elapsed),
                    style: TextStyle(
                      color:      _accent,
                      fontWeight: FontWeight.bold,
                      fontSize:   15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Progress field
            TextField(
              controller:     controller,
              keyboardType:   TextInputType.number,
              autofocus:      true,
              decoration: InputDecoration(
                labelText: widget.data.progressPrompt,
                hintText:  'Desde ${widget.data.currentProgress}',
                prefixIcon: Icon(
                  Icons.bookmark_added_rounded,
                  color: _accent,
                  size:  20,
                ),
                filled:    true,
                fillColor: AppColors.card(sheetCtx),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:   BorderSide(color: AppColors.border(sheetCtx)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:   BorderSide(color: _accent, width: 1.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:   BorderSide.none,
                ),
                floatingLabelStyle: TextStyle(
                  color:      _accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  final val = int.tryParse(controller.text);
                  if (val != null && val >= widget.data.currentProgress) {
                    Navigator.pop(sheetCtx);
                    await _saveProgress(val);
                  } else {
                    ScaffoldMessenger.of(sheetCtx).showSnackBar(
                      const SnackBar(
                        content:  Text('Introduce un número válido.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon:  const Icon(Icons.save_rounded),
                label: const Text('Guardar y salir'),
                style: FilledButton.styleFrom(
                  backgroundColor: _accent,
                  padding:         const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Save progress
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _saveProgress(int newProgress) async {
    final shouldPromptEdit =
        widget.data.totalProgress != null &&
        newProgress >= widget.data.totalProgress!;

    setState(() => _isSaving = true);

    try {
      final user              = await ref.read(authRepositoryProvider).getUserProfile();
      final elapsedSeconds    = ref.read(readingTimerProvider).elapsedSeconds;
      final progressDelta     = newProgress - widget.data.currentProgress;

      switch (widget.data.mediaType) {
        case SessionMediaType.book:
          final journal = widget.data.rawJournal as BookJournalResponseDto;
          final book    = journal.book;
          await ref.read(bookJournalRepositoryProvider).saveRaw(
            BookJournalRecordDTO(
              id:             journal.id,
              userId:         user.idUser,
              bookId:         book.idBook,
              googleBooksId:  book.googleBooksId,
              status:         journal.status,
              currentPage:    newProgress,
              rating:         journal.rating,
              tearDrops:      journal.tearDrops,
              spiceFlames:    journal.spiceFlames,
              readingFormat:  journal.readingFormat,
              emotions:       journal.emotions,
              favoriteQuotes: journal.favoriteQuotes,
              personalNotes:  journal.personalNotes,
              startDate:      journal.startDate,
              endDate:        journal.endDate,
              ownership:      journal.ownership,
            ).toJson(),
          );
          ref.invalidate(journalProvider(JournalType.book));
          ref.invalidate(journalEntryProvider((JournalType.book, book.idBook ?? 0)));

        case SessionMediaType.manga:
          final journal = widget.data.rawJournal as MangaJournalResponseDTO;
          final manga   = journal.manga;
          await ref.read(mangaJournalRepositoryProvider).saveRaw(
            MangaJournalRecordDTO(
              id:                journal.id,
              userId:            user.idUser,
              mangaId:           manga?.idManga,
              malId:             manga?.malId,
              status:            journal.status,
              currentChapter:    newProgress,
              rating:            journal.rating,
              readingFormat:     journal.readingFormat,
              favoriteCharacter: journal.favoriteCharacter,
              favoriteArc:       journal.favoriteArc,
              personalNotes:     journal.personalNotes,
              startDate:         journal.startDate,
              endDate:           journal.endDate,
            ).toJson(),
          );
          ref.invalidate(journalProvider(JournalType.manga));
          ref.invalidate(journalEntryProvider((JournalType.manga, manga?.idManga ?? 0)));

        case SessionMediaType.fanfic:
          final journal = widget.data.rawJournal as FanficJournalResponseDTO;
          final fanfic  = journal.fanfic;
          await ref.read(fanficJournalRepositoryProvider).saveRaw(
            FanficJournalRecordDTO(
              id:             journal.id,
              userId:         user.idUser,
              fanficId:       fanfic.idFanfic ?? 0,
              ao3Id:          fanfic.ao3Id,
              status:         journal.status,
              currentChapter: newProgress,
              rating:         journal.rating,
              tearDrops:      journal.tearDrops,
              spiceFlames:    journal.spiceFlames,
              personalNotes:  journal.personalNotes,
              startDate:      journal.startDate,
              endDate:        journal.endDate,
            ).toJson(),
          );
          ref.invalidate(journalProvider(JournalType.fanfic));
          ref.invalidate(journalEntryProvider((JournalType.fanfic, fanfic.idFanfic ?? 0)));
      }

      // Unificamos el guardado de la sesión y la racha fuera del switch para no repetirlo
      if (progressDelta > 0 || elapsedSeconds > 0) {
        ref.read(readingSessionRepositoryProvider).saveSession(
          ReadingSessionRecordDTO(
            userId:          user.idUser,
            bookId:          widget.data.mediaType == SessionMediaType.book ? widget.data.itemId : null,
            mangaId:         widget.data.mediaType == SessionMediaType.manga ? widget.data.itemId : null,
            fanficId:        widget.data.mediaType == SessionMediaType.fanfic ? widget.data.itemId : null,
            durationSeconds: elapsedSeconds,
            pagesRead:       progressDelta,
          ),
        );
        
        // Registramos la actividad de hoy explícitamente para que la racha se incremente
        await ref.read(readingStatsRepositoryProvider).recordActivity();
        ref.invalidate(gamificationProvider);
      }

      ref.read(readingTimerProvider.notifier).reset();

      if (!mounted) return;
      Navigator.pop(context);

      if (shouldPromptEdit) _showFinishedPrompt();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:         Text('Error al guardar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior:        SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(readingTimerProvider);
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final bgColor    = isDark
        ? const Color(0xFF1E1E1E)
        : _accent.withValues(alpha:0.05);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation:       0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Cover ────────────────────────────────────────────
                _Cover(
                  coverUrl: widget.data.coverUrl,
                  accent:   _accent,
                  type:     widget.data.mediaType,
                ),
                const SizedBox(height: 28),

                // ── Title ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    widget.data.title,
                    textAlign:  TextAlign.center,
                    maxLines:   2,
                    overflow:   TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Progress label ───────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color:        _accent.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(20),
                    border:       Border.all(color: _accent.withValues(alpha:0.25)),
                  ),
                  child: Text(
                    '${widget.data.progressPrompt}: ${widget.data.currentProgress}'
                    '${widget.data.totalProgress != null ? ' / ${widget.data.totalProgress}' : ''}',
                    style: TextStyle(
                      fontSize:   12,
                      color:      _accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // ── Timer ────────────────────────────────────────────
                Text(
                  _formatTime(timerState.elapsedSeconds),
                  style: TextStyle(
                    fontSize:     72,
                    fontWeight:   FontWeight.w300,
                    color:        AppColors.textPrimary(context),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 40),

                // ── Controls ─────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Play / Pause
                    FloatingActionButton.large(
                      heroTag:         'play_pause',
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      elevation:       0,
                      onPressed: () {
                        if (timerState.isRunning) {
                          ref.read(readingTimerProvider.notifier).pause();
                        } else {
                          ref.read(readingTimerProvider.notifier).start(
                            widget.data.itemId,
                            widget.data.timerItemType,
                          );
                        }
                      },
                      child: Icon(
                        timerState.isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Stop
                    FloatingActionButton.large(
                      heroTag:         'stop',
                      backgroundColor: timerState.elapsedSeconds > 0
                          ? Theme.of(context).colorScheme.errorContainer
                          : Theme.of(context).disabledColor,
                      foregroundColor: timerState.elapsedSeconds > 0
                          ? Theme.of(context).colorScheme.onErrorContainer
                          : Colors.white,
                      elevation: 0,
                      onPressed: timerState.elapsedSeconds > 0
                          ? _finishSession
                          : null,
                      child: const Icon(Icons.stop_rounded, size: 40),
                    ),
                    const SizedBox(width: 20),

                    // Add note
                    // FIX: renamed from 'brain' — icon updated to match NotesTab
                    FloatingActionButton(
                      heroTag:         'notes',
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                      elevation:       0,
                      tooltip:         'Añadir nota',
                      onPressed:       _openAddNoteSheet,
                      child: const Icon(Icons.edit_note_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Hint ─────────────────────────────────────────────
                Text(
                  'Desliza hacia abajo para ocultar.\nEl temporizador seguirá activo.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:  AppColors.textSecondary(context),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Note sheet
  // FIX: was calling AddEntrySheet(ref: ref, ...) — both the class name and
  //      the ref parameter were changed when we improved notes_tab.dart.
  //      Now uses AddNoteSheet without the redundant ref parameter.
  // ─────────────────────────────────────────────────────────────────────────

  void _openAddNoteSheet() {
    showModalBottomSheet<void>(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => AddNoteSheet(
        itemType: _itemTypeString,
        itemId:   widget.data.itemId,
        accent:   _accent,
        // ref parameter removed — AddNoteSheet is a ConsumerStatefulWidget
        // and gets its own ref automatically.
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Finished prompt  (bottom sheet instead of AlertDialog — more natural)
  // ─────────────────────────────────────────────────────────────────────────

  void _showFinishedPrompt() {
    showModalBottomSheet<void>(
      context:             context,
      barrierColor:        Colors.black.withValues(alpha:0.4),
      backgroundColor:     Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width:  40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color:        Theme.of(sheetCtx).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Trophy icon
            Container(
              width:  64, height: 64,
              decoration: BoxDecoration(
                color:        _accent.withValues(alpha:0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.emoji_events_rounded,
                  color: _accent, size: 30),
            ),
            const SizedBox(height: 16),

            Text(
              '¡Has terminado el libro!',
              style: Theme.of(sheetCtx).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '¿Quieres actualizar tu diario y añadir valoraciones?',
              style: Theme.of(sheetCtx).textTheme.bodyMedium?.copyWith(
                color:  AppColors.textSecondary(sheetCtx),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Edit journal
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  final extra = widget.data.rawJournal;
                  final route = switch (widget.data.mediaType) {
                    SessionMediaType.book   => '/journal/book/edit',
                    SessionMediaType.manga  => '/journal/manga/edit',
                    SessionMediaType.fanfic => '/journal/fanfic/edit',
                  };
                  context.go(route, extra: extra);
                },
                icon:  const Icon(Icons.edit_rounded),
                label: const Text('Editar diario'),
                style: FilledButton.styleFrom(
                  backgroundColor: _accent,
                  padding:         const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Dismiss
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(sheetCtx),
                style: OutlinedButton.styleFrom(
                  side:    BorderSide(color: AppColors.border(sheetCtx)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Más tarde'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _Cover
// ─────────────────────────────────────────────────────────────────────────────

class _Cover extends StatelessWidget {
  final String?          coverUrl;
  final Color            accent;
  final SessionMediaType type;

  const _Cover({
    required this.coverUrl,
    required this.accent,
    required this.type,
  });

  IconData get _fallbackIcon => switch (type) {
        SessionMediaType.book   => Icons.book_rounded,
        SessionMediaType.manga  => Icons.menu_book_rounded,
        SessionMediaType.fanfic => Icons.favorite_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color:      accent.withValues(alpha:0.4),
            blurRadius: 30,
            offset:     const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width:  140,
          height: 210,
          child: coverUrl != null && coverUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl:    coverUrl!,
                  fit:         BoxFit.cover,
                  placeholder: (_, _) =>
                      Container(color: accent.withValues(alpha:0.12)),
                  errorWidget: (_, _, _) => _CoverFallback(
                    accent: accent,
                    icon:   _fallbackIcon,
                  ),
                )
              : _CoverFallback(accent: accent, icon: _fallbackIcon),
        ),
      ),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  final Color    accent;
  final IconData icon;
  const _CoverFallback({required this.accent, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        color: accent.withValues(alpha:0.12),
        child: Center(
          child: Icon(icon, size: 48, color: accent.withValues(alpha:0.5)),
        ),
      );
}