import 'dart:ui';
import 'package:between_pages/models/journal/book_journal_record_dto.dart';
import 'package:between_pages/models/journal/book_journal_response_dto.dart';
import 'package:between_pages/models/journal/manga_journal_record_dto.dart';
import 'package:between_pages/models/journal/manga_journal_response_dto.dart';
import 'package:between_pages/models/journal/fanfic_journal_record_dto.dart';
import 'package:between_pages/models/journal/fanfic_journal_response_dto.dart';
import 'package:between_pages/models/journal/reading_session_record_dto.dart';
import 'package:between_pages/providers/journal/book_journal_provider.dart';
import 'package:between_pages/providers/journal/manga_journal_provider.dart';
import 'package:between_pages/providers/journal/fanfic_journal_provider.dart';
import 'package:between_pages/providers/journal/reading_timer_provider.dart';
import 'package:between_pages/repositories/auth_repository.dart';
import 'package:between_pages/repositories/book_journal_repository.dart';
import 'package:between_pages/repositories/manga_journal_repository.dart';
import 'package:between_pages/repositories/fanfic_journal_repository.dart';
import 'package:between_pages/repositories/reading_session_repository.dart';
import 'package:between_pages/providers/gamification_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum SessionMediaType { book, manga, fanfic }

class UniversalSessionData {
  final SessionMediaType mediaType;
  final int itemId;
  final ReadingItemType timerItemType;
  final String title;
  final String? coverUrl;
  final int currentProgress;
  final String progressPrompt;
  final Color accentColor;
  final dynamic rawJournal; // Referencia al DTO original (Book, Manga, Fanfic)

  UniversalSessionData({
    required this.mediaType,
    required this.itemId,
    required this.timerItemType,
    required this.title,
    this.coverUrl,
    required this.currentProgress,
    required this.progressPrompt,
    required this.accentColor,
    required this.rawJournal,
  });
}

class UniversalSessionPage extends ConsumerStatefulWidget {
  final UniversalSessionData data;

  const UniversalSessionPage({super.key, required this.data});

  @override
  ConsumerState<UniversalSessionPage> createState() => _UniversalSessionPageState();
}

class _UniversalSessionPageState extends ConsumerState<UniversalSessionPage> {
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.data.itemId > 0) {
        ref.read(readingTimerProvider.notifier).start(widget.data.itemId, widget.data.timerItemType);
      }
    });
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _finishSession() {
    ref.read(readingTimerProvider.notifier).pause();
    final timerState = ref.read(readingTimerProvider);
    final currentProgress = widget.data.currentProgress;
    final controller = TextEditingController(text: currentProgress.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  )),
                ),
                const SizedBox(height: 20),
                Text('¡Sesión finalizada!', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Tiempo invertido: ${_formatTime(timerState.elapsedSeconds)}', style: TextStyle(color: widget.data.accentColor, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: widget.data.progressPrompt,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    prefixIcon: const Icon(Icons.bookmark_added_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      final val = int.tryParse(controller.text);
                      if (val != null && val >= currentProgress) {
                        Navigator.pop(context);
                        await _saveProgress(val);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Por favor, introduce un número válido.')),
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: widget.data.accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 14)
                    ),
                    child: const Text('Guardar y salir'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveProgress(int newProgress) async {
    setState(() => _isSaving = true);
    try {
      final auth = ref.read(authRepositoryProvider);
      final user = await auth.getUserProfile();
      final timeInvestedSeconds = ref.read(readingTimerProvider).elapsedSeconds;
      final progressDelta = newProgress - widget.data.currentProgress;

      switch (widget.data.mediaType) {
        case SessionMediaType.book:
          final journal = widget.data.rawJournal as BookJournalResponseDto;
          final book = journal.book;
          final repo = ref.read(bookJournalRepositoryProvider);
          final dto = BookJournalRecordDTO(
            userId: user.idUser,
            bookId: book.idBook > 0 ? book.idBook : null,
            googleBooksId: book.googleBooksId.isNotEmpty ? book.googleBooksId : null,
            title: book.title.isNotEmpty ? book.title : null,
            author: book.author.isNotEmpty ? book.author : null,
            isbn: book.isbn,
            publisher: book.publisher,
            description: book.description,
            coverUrl: book.coverUrl,
            genre: book.genre,
            publicationYear: book.publishYear,
            status: journal.status,
            currentPage: newProgress,
            rating: journal.rating,
            tearDrops: journal.tearDrops,
            spiceFlames: journal.spiceFlames,
            readingFormat: journal.readingFormat,
            emotions: journal.emotions,
            favoriteQuotes: journal.favoriteQuotes,
            personalNotes: journal.personalNotes,
            startDate: journal.startDate,
            endDate: journal.endDate,
            ownership: journal.ownership,
          );
          await repo.saveOrUpdate(dto);
          ref.invalidate(bookJournalProvider);
          ref.invalidate(bookJournalEntryProvider(book.idBook));

          if (progressDelta > 0 || timeInvestedSeconds > 0) {
            ref.read(readingSessionRepositoryProvider).saveSession(ReadingSessionRecordDTO(
              userId: user.idUser,
              bookId: book.idBook,
              durationSeconds: timeInvestedSeconds,
              pagesRead: progressDelta,
            ));
            // Al terminar la sesión, recargamos la gamificación para actualizar la racha 🔥
            ref.invalidate(gamificationProvider);
          }
          break;

        case SessionMediaType.manga:
          final journal = widget.data.rawJournal as MangaJournalResponseDTO;
          final manga = journal.manga;
          final repo = ref.read(mangaJournalRepositoryProvider);
          final dto = MangaJournalRecordDTO(
            userId: user.idUser,
            mangaId: manga?.idManga ?? 0,
            status: journal.status ?? 'READING',
            currentChapter: newProgress,
            rating: journal.rating,
            readingFormat: journal.readingFormat,
            favoriteCharacter: journal.favoriteCharacter,
            favoriteArc: journal.favoriteArc,
            personalNotes: journal.personalNotes,
            startDate: journal.startDate,
            endDate: journal.endDate,
          );
          await repo.saveOrUpdate(dto);
          ref.invalidate(mangaJournalProvider);

          if (progressDelta > 0 || timeInvestedSeconds > 0) {
            ref.read(readingSessionRepositoryProvider).saveSession(ReadingSessionRecordDTO(
              userId: user.idUser,
              mangaId: manga?.idManga ?? 0,
              durationSeconds: timeInvestedSeconds,
              pagesRead: progressDelta,
            ));
            ref.invalidate(gamificationProvider);
          }
          break;

        case SessionMediaType.fanfic:
          final journal = widget.data.rawJournal as FanficJournalResponseDTO;
          final fanfic = journal.fanfic;
          final repo = ref.read(fanficJournalRepositoryProvider);
          final dto = FanficJournalRecordDTO(
            userId: user.idUser,
            fanfictionId: fanfic?.idFanfic ?? 0,
            ao3Id: fanfic?.ao3Id,
            title: fanfic?.title,
            author: fanfic?.author,
            sourceMaterial: fanfic?.sourceMaterial,
            description: fanfic?.description,
            coverUrl: fanfic?.coverUrl,
            genre: fanfic?.genre,
            theme: fanfic?.theme,
            totalChapters: fanfic?.totalChapters,
            publicationStatus: fanfic?.publicationStatus,
            status: journal.status ?? 'READING',
            currentChapter: newProgress,
            rating: journal.rating,
            tearDrops: journal.tearDrops,
            spiceFlames: journal.spiceFlames,
            personalNotes: journal.personalNotes,
            startDate: journal.startDate,
            endDate: journal.endDate,
          );
          await repo.saveOrUpdate(dto);
          ref.invalidate(fanficJournalProvider);

          if (progressDelta > 0 || timeInvestedSeconds > 0) {
            ref.read(readingSessionRepositoryProvider).saveSession(ReadingSessionRecordDTO(
              userId: user.idUser,
              fanficId: fanfic?.idFanfic ?? 0,
              durationSeconds: timeInvestedSeconds,
              pagesRead: progressDelta,
            ));
            ref.invalidate(gamificationProvider);
          }
          break;
      }

      ref.read(readingTimerProvider.notifier).reset();
      if (mounted) context.pop();
      
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(readingTimerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Usamos el color de acento de forma dinámica según el tipo de lectura
    final accent = widget.data.accentColor;
    final bgContainer = isDark ? const Color(0xFF1E1E1E) : accent.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: bgContainer,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 32),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Portada Dinámica
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(color: accent.withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, 10))
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 140, height: 210,
                      child: widget.data.coverUrl != null && widget.data.coverUrl!.isNotEmpty
                          ? CachedNetworkImage(imageUrl: widget.data.coverUrl!, fit: BoxFit.cover)
                          : Container(color: Colors.grey, child: const Icon(Icons.menu_book, size: 40)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Título
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    widget.data.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 40),

                // Cronómetro
                Text(
                  _formatTime(timerState.elapsedSeconds),
                  style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w300, fontFeatures: [FontFeature.tabularFigures()]),
                ),
                const SizedBox(height: 40),

                // Controles de Play / Stop
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton.large(
                      heroTag: 'play_pause',
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      onPressed: () {
                        if (timerState.isRunning) {
                          ref.read(readingTimerProvider.notifier).pause();
                        } else {
                          ref.read(readingTimerProvider.notifier).start(widget.data.itemId, widget.data.timerItemType);
                        }
                      },
                      child: Icon(timerState.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 40),
                    ),
                    const SizedBox(width: 24),
                    FloatingActionButton.large(
                      heroTag: 'stop',
                      backgroundColor: timerState.elapsedSeconds > 0 
                          ? Theme.of(context).colorScheme.errorContainer 
                          : Theme.of(context).disabledColor,
                      foregroundColor: timerState.elapsedSeconds > 0 
                          ? Theme.of(context).colorScheme.onErrorContainer 
                          : Colors.white,
                      elevation: 0,
                      onPressed: timerState.elapsedSeconds > 0 ? _finishSession : null,
                      child: const Icon(Icons.stop_rounded, size: 40),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Desliza hacia abajo para ocultar, el temporizador seguirá activo.",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}