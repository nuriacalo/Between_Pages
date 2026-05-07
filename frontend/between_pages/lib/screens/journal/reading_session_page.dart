import 'package:between_pages/models/journal/book_journal_record_dto.dart';
import 'package:between_pages/models/journal/book_journal_response_dto.dart';
import 'package:between_pages/models/journal/reading_session_record_dto.dart';
import 'package:between_pages/providers/journal/book_journal_provider.dart';
import 'package:between_pages/providers/journal/reading_timer_provider.dart';
import 'package:between_pages/repositories/auth_repository.dart';
import 'package:between_pages/repositories/book_journal_repository.dart';
import 'package:between_pages/repositories/reading_session_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ReadingSessionPage extends ConsumerStatefulWidget {
  final BookJournalResponseDto journal;

  const ReadingSessionPage({super.key, required this.journal});

  @override
  ConsumerState<ReadingSessionPage> createState() => _ReadingSessionPageState();
}

class _ReadingSessionPageState extends ConsumerState<ReadingSessionPage> {
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Iniciamos el cronómetro automáticamente al entrar si el libro tiene ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.journal.book.idBook > 0) {
        ref.read(readingTimerProvider.notifier).start(widget.journal.book.idBook, ReadingItemType.book);
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
    final currentPg = widget.journal.currentPage ?? 0;
    final controller = TextEditingController(text: currentPg.toString());

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
                    labelText: '¿En qué página te has quedado?',
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
                      if (val != null && val >= currentPg) {
                        Navigator.pop(context); // Cerrar bottom sheet
                        await _saveProgress(val);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Por favor, introduce una página válida.')),
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
    ).whenComplete(() {
      // Si el usuario descarta el modal sin guardar, reanudamos o permitimos que decida
    });
  }

  Future<void> _saveProgress(int newPage) async {
    setState(() => _isSaving = true);
    try {
      final auth = ref.read(authRepositoryProvider);
      final repo = ref.read(bookJournalRepositoryProvider);
      final user = await auth.getUserProfile();
      final book = widget.journal.book;

      // 1. Calcular métricas de la sesión
      final currentPg = widget.journal.currentPage ?? 0;
      final pagesRead = newPage - currentPg;
      final timeInvestedSeconds = ref.read(readingTimerProvider).elapsedSeconds;

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
        status: widget.journal.status,
        currentPage: newPage,
        rating: widget.journal.rating,
        tearDrops: widget.journal.tearDrops,
        spiceFlames: widget.journal.spiceFlames,
        readingFormat: widget.journal.readingFormat,
        emotions: widget.journal.emotions,
        favoriteQuotes: widget.journal.favoriteQuotes,
        personalNotes: widget.journal.personalNotes,
        startDate: widget.journal.startDate,
        endDate: widget.journal.endDate,
        ownership: widget.journal.ownership,
      );

      await repo.saveOrUpdate(dto);
      ref.invalidate(bookJournalProvider);
      ref.invalidate(bookJournalEntryProvider(book.idBook));

      // 2. Guardar las métricas de la sesión (si se ha leído algo)
      if (pagesRead > 0 || timeInvestedSeconds > 0) {
        final sessionDto = ReadingSessionRecordDTO(
          userId: user.idUser,
          bookId: book.idBook,
          durationSeconds: timeInvestedSeconds,
          pagesRead: pagesRead,
        );
        // Llamamos al repositorio sin 'await' para no bloquear al usuario.
        // El guardado de la sesión es secundario al del progreso del journal.
        ref.read(readingSessionRepositoryProvider).saveSession(sessionDto);
        debugPrint(
            'Enviando sesión: $pagesRead páginas en $timeInvestedSeconds segundos.');
      }

      // 3. Limpiar y salir
      ref.read(readingTimerProvider.notifier).reset(); // Limpiar cronómetro
      if (mounted) context.pop(); // Volver a la pantalla anterior
      
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
    final bgAccent = const Color(0xFFA87C80);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFDF5F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 32),
          onPressed: () => context.pop(), // Permite salir sin finalizar (el cronómetro sigue)
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
                      BoxShadow(color: bgAccent.withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, 10))
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 140, height: 210,
                      child: widget.journal.book.coverUrl != null
                          ? CachedNetworkImage(imageUrl: widget.journal.book.coverUrl!, fit: BoxFit.cover)
                          : Container(color: Colors.grey, child: const Icon(Icons.book, size: 40)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Título
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    widget.journal.book.title,
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
                    // Botón Play/Pause
                    FloatingActionButton.large(
                      heroTag: 'play_pause',
                      backgroundColor: bgAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      onPressed: () {
                        if (timerState.isRunning) {
                          ref.read(readingTimerProvider.notifier).pause();
                        } else {
                          ref.read(readingTimerProvider.notifier).start(widget.journal.book.idBook, ReadingItemType.book);
                        }
                      },
                      child: Icon(timerState.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 40),
                    ),
                    const SizedBox(width: 24),
                    // Botón Finalizar
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
                  'Desliza hacia abajo para ocultar, el temporizador seguirá activo.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}