import 'package:between_pages/models/journal/manga_journal_record_dto.dart';
import 'package:between_pages/models/journal/manga_journal_response_dto.dart';
import 'package:between_pages/models/journal/reading_session_record_dto.dart';
import 'package:between_pages/providers/journal/manga_journal_provider.dart';
import 'package:between_pages/providers/journal/reading_timer_provider.dart';
import 'package:between_pages/repositories/auth_repository.dart';
import 'package:between_pages/repositories/manga_journal_repository.dart';
import 'package:between_pages/repositories/reading_session_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MangaReadingSessionPage extends ConsumerStatefulWidget {
  final MangaJournalResponseDTO journal;

  const MangaReadingSessionPage({super.key, required this.journal});

  @override
  ConsumerState<MangaReadingSessionPage> createState() => _MangaReadingSessionPageState();
}

class _MangaReadingSessionPageState extends ConsumerState<MangaReadingSessionPage> {
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mangaId = widget.journal.manga?.idManga;
      if (mangaId != null && mangaId > 0) {
        ref.read(readingTimerProvider.notifier).start(mangaId, ReadingItemType.manga);
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
    final currentChapter = widget.journal.currentChapter ?? 0;
    final controller = TextEditingController(text: currentChapter.toString());

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
                Text('Tiempo invertido: ${_formatTime(timerState.elapsedSeconds)}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: '¿En qué capítulo/volumen te has quedado?',
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
                      if (val != null && val >= currentChapter) {
                        Navigator.pop(context);
                        await _saveProgress(val);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Por favor, introduce un capítulo válido.')),
                        );
                      }
                    },
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
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

  Future<void> _saveProgress(int newChapter) async {
    setState(() => _isSaving = true);
    try {
      final auth = ref.read(authRepositoryProvider);
      final repo = ref.read(mangaJournalRepositoryProvider);
      final user = await auth.getUserProfile();
      final manga = widget.journal.manga;

      final currentChapter = widget.journal.currentChapter ?? 0;
      final chaptersRead = newChapter - currentChapter;
      final timeInvestedSeconds = ref.read(readingTimerProvider).elapsedSeconds;

      final dto = MangaJournalRecordDTO(
        userId: user.idUser,
        mangaId: manga?.idManga ?? 0,
        status: widget.journal.status ?? 'READING',
        currentChapter: newChapter,
        rating: widget.journal.rating,
        readingFormat: widget.journal.readingFormat,
        favoriteCharacter: widget.journal.favoriteCharacter,
        favoriteArc: widget.journal.favoriteArc,
        personalNotes: widget.journal.personalNotes,
        startDate: widget.journal.startDate,
        endDate: widget.journal.endDate,
      );

      await repo.saveOrUpdate(dto);
      ref.invalidate(mangaJournalProvider);

      if (chaptersRead > 0 || timeInvestedSeconds > 0) {
      final sessionDto = ReadingSessionRecordDTO(
        userId: user.idUser,
        mangaId: manga?.idManga ?? 0,
        durationSeconds: timeInvestedSeconds,
        pagesRead: chaptersRead,
      );
        ref.read(readingSessionRepositoryProvider).saveSession(sessionDto);
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
    final bgAccent = const Color(0xFF6B7280); // Manga accent color

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8FAFC),
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
                // Portada
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(color: bgAccent.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 10))
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 140, height: 210,
                      child: (widget.journal.manga?.coverUrl ?? '').isNotEmpty
                          ? CachedNetworkImage(imageUrl: widget.journal.manga!.coverUrl!, fit: BoxFit.cover)
                          : Container(color: Colors.grey, child: const Icon(Icons.auto_stories, size: 40)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Título
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    widget.journal.manga?.title ?? 'Manga sin título',
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

                // Controles
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Play/Pause
                    FloatingActionButton.large(
                      heroTag: 'play_pause_manga',
                      backgroundColor: bgAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      onPressed: () {
                        final mangaId = widget.journal.manga?.idManga ?? 0;
                        if (timerState.isRunning) {
                          ref.read(readingTimerProvider.notifier).pause();
                        } else {
                          ref.read(readingTimerProvider.notifier).start(mangaId, ReadingItemType.manga);
                        }
                      },
                      child: Icon(timerState.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 40),
                    ),
                    const SizedBox(width: 24),
                    // Stop
                    FloatingActionButton.large(
                      heroTag: 'stop_manga',
                      backgroundColor: timerState.elapsedSeconds > 0 
                          ? Theme.of(context).colorScheme.errorContainer 
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                      foregroundColor: timerState.elapsedSeconds > 0 
                          ? Theme.of(context).colorScheme.onErrorContainer 
                          : null,
                      elevation: 0,
                      onPressed: timerState.elapsedSeconds > 0 ? _finishSession : null,
                      child: const Icon(Icons.stop_rounded, size: 40),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Desliza hacia abajo para ocultar, el temporizador seguirá activo.',
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
