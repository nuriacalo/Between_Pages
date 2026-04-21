import 'package:between_pages/models/journal/book_journal_response_dto.dart';
import 'package:between_pages/models/journal/manga_journal_response_dto.dart';
import 'package:between_pages/providers/journal/book_journal_provider.dart';
import 'package:between_pages/providers/journal/manga_journal_provider.dart';
import 'package:between_pages/screens/library/unified_dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Deberías tener un repositorio para el journal.
// final journalRepositoryProvider = Provider(...);

class UpdateProgressDialog extends ConsumerStatefulWidget {
  final dynamic journalEntry;

  const UpdateProgressDialog({super.key, required this.journalEntry});

  @override
  ConsumerState<UpdateProgressDialog> createState() => _UpdateProgressDialogState();
}

class _UpdateProgressDialogState extends ConsumerState<UpdateProgressDialog> {
  late double _currentProgress;
  late int _maxProgress;
  late String _unit;
  late TextEditingController _textController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeState();
    _textController = TextEditingController(text: _currentProgress.toInt().toString());
  }

  void _initializeState() {
    final entry = widget.journalEntry;
    if (entry is BookJournalResponseDto) {
      _currentProgress = entry.currentPage.toDouble();
      _maxProgress = entry.book.pageCount;
      _unit = 'Página';
    } else if (entry is MangaJournalResponseDTO) {
      _currentProgress = entry.currentChapter.toDouble();
      _maxProgress = entry.manga.chapters ?? 1;
      _unit = 'Capítulo';
    } else {
      _currentProgress = 0;
      _maxProgress = 1;
      _unit = 'Unidad';
    }
    if (_maxProgress <= 0) _maxProgress = 1;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Aquí va la llamada a tu repositorio para actualizar el backend.
      // await ref.read(journalRepositoryProvider).updateProgress(
      //   id: widget.journalEntry.id,
      //   type: widget.journalEntry is BookJournalResponseDto ? 'book' : 'manga',
      //   progress: _currentProgress.toInt(),
      // );
      await Future.delayed(const Duration(seconds: 1)); // Simulación de red

      ref.invalidate(unifiedReadingDashboardProvider);
      if (widget.journalEntry is BookJournalResponseDto) {
        ref.invalidate(bookJournalProvider);
      } else if (widget.journalEntry is MangaJournalResponseDTO) {
        ref.invalidate(mangaJournalProvider);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (title, _) = _extractDetails();
    final percentage = (_currentProgress / _maxProgress * 100).clamp(0, 100);

    return AlertDialog(
      title: Text('Actualizar Progreso'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Text(
              '$_unit ${_currentProgress.toInt()} de $_maxProgress (${percentage.toStringAsFixed(0)}%)',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Slider(
              value: _currentProgress,
              min: 0,
              max: _maxProgress.toDouble(),
              divisions: _maxProgress > 0 ? _maxProgress : null,
              label: _currentProgress.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentProgress = value;
                  _textController.text = value.toInt().toString();
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                controller: _textController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: '$_unit actual', suffixText: '/ $_maxProgress'),
                onChanged: (value) {
                  final intValue = int.tryParse(value) ?? 0;
                  setState(() {
                    _currentProgress = intValue.clamp(0, _maxProgress).toDouble();
                  });
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        FilledButton(
          onPressed: _isLoading ? null : _onSave,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Guardar'),
        ),
      ],
    );
  }

  (String, String?) _extractDetails() {
    if (widget.journalEntry is BookJournalResponseDto) {
      final book = (widget.journalEntry as BookJournalResponseDto).book;
      return (book.title, book.thumbnailUrl);
    }
    if (widget.journalEntry is MangaJournalResponseDTO) {
      final manga = (widget.journalEntry as MangaJournalResponseDTO).manga;
      return (manga.title, manga.imageUrl);
    }
    return ('Título desconocido', null);
  }
}
