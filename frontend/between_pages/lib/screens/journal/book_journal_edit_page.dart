import 'package:between_pages/models/journal/book_journal_record_dto.dart';
import 'package:between_pages/models/journal/book_journal_response_dto.dart';
import 'package:between_pages/providers/journal/book_journal_provider.dart';
import 'package:between_pages/repositories/book_journal_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BookJournalEditPage extends ConsumerStatefulWidget {
  final BookJournalResponseDto journal;

  const BookJournalEditPage({super.key, required this.journal});

  @override
  ConsumerState<BookJournalEditPage> createState() => _BookJournalEditPageState();
}

class _BookJournalEditPageState extends ConsumerState<BookJournalEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Controllers for Módulo 2
  late final TextEditingController _seriesNameController;
  late final TextEditingController _seriesOrderController;
  late final TextEditingController _loanedToController;

  // Other controllers
  late final TextEditingController _currentPageController;
  late final TextEditingController _personalNotesController;
  late final TextEditingController _favoriteQuotesController;
  late String _status;

  @override
  void initState() {
    super.initState();
    final journal = widget.journal;
    _seriesNameController = TextEditingController(text: journal.seriesName);
    _seriesOrderController =
        TextEditingController(text: journal.seriesOrder?.toString());
    _loanedToController = TextEditingController(text: journal.loanedTo);
    _currentPageController =
        TextEditingController(text: journal.currentPage?.toString() ?? '0');
    _personalNotesController = TextEditingController(text: journal.personalNotes);
    _favoriteQuotesController = TextEditingController(text: journal.favoriteQuotes);
    _status = journal.status ?? 'PENDING';
  }

  @override
  void dispose() {
    _seriesNameController.dispose();
    _seriesOrderController.dispose();
    _loanedToController.dispose();
    _currentPageController.dispose();
    _personalNotesController.dispose();
    _favoriteQuotesController.dispose();
    super.dispose();
  }

  Future<void> _saveJournal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final oldJournal = widget.journal;
      final book = oldJournal.book;

      final dto = BookJournalRecordDTO(
        userId: oldJournal.userId,
        bookId: book.idBook,
        // Copy all existing fields from the old journal
        status: _status,
        rating: oldJournal.rating,
        tearDrops: oldJournal.tearDrops,
        spiceFlames: oldJournal.spiceFlames,
        readingFormat: oldJournal.readingFormat,
        emotions: oldJournal.emotions,
        startDate: oldJournal.startDate,
        endDate: oldJournal.endDate,
        rereading: oldJournal.rereading,
        ownership: oldJournal.ownership,
        // Update with new values from controllers
        currentPage: int.tryParse(_currentPageController.text) ?? oldJournal.currentPage,
        personalNotes: _personalNotesController.text,
        favoriteQuotes: _favoriteQuotesController.text,
        seriesName: _seriesNameController.text.isNotEmpty ? _seriesNameController.text : null,
        seriesOrder: _seriesOrderController.text.isNotEmpty ? double.tryParse(_seriesOrderController.text) : null,
        loanedTo: _loanedToController.text.isNotEmpty ? _loanedToController.text : null,
      );

      await ref.read(bookJournalRepositoryProvider).saveOrUpdate(dto);

      // Invalidate providers to refresh data across the app
      ref.invalidate(bookJournalProvider);
      ref.invalidate(bookJournalEntryProvider(book.idBook));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal actualizado con éxito')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Journal'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
            )
          else
            IconButton(
              icon: const Icon(Icons.save_alt_outlined),
              onPressed: _saveJournal,
              tooltip: 'Guardar',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(widget.journal.book.title, style: Theme.of(context).textTheme.headlineSmall),
            Text(widget.journal.book.author, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 24),

            // --- Módulo 2: Organización ---
            Text('Organización', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 20),

            TextFormField(
              controller: _seriesNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la Saga/Serie',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.collections_bookmark_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _seriesOrderController,
              decoration: const InputDecoration(
                labelText: 'Orden en la saga (ej: 1, 1.5, 2)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.format_list_numbered),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _loanedToController,
              decoration: const InputDecoration(
                labelText: 'Prestado a...',
                hintText: 'Nombre de la persona y fecha',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_pin_outlined),
              ),
            ),
            const SizedBox(height: 24),

            // --- Progreso y Notas ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('El Segundo Cerebro', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                IconButton.filledTonal(
                  icon: const Icon(Icons.document_scanner_outlined),
                  tooltip: 'Escanear texto (OCR)',
                  onPressed: () async {
                    final scannedText = await context.push<String>('/ocr-scanner');
                    if (scannedText != null && scannedText.isNotEmpty) {
                      setState(() {
                        final current = _favoriteQuotesController.text.trim();
                        _favoriteQuotesController.text = current.isEmpty
                            ? scannedText
                            : '$current\n\n$scannedText';
                      });
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Texto extraído y añadido con éxito')),
                      );
                    }
                  },
                ),
              ],
            ),
            const Divider(height: 16),

            TextFormField(
              controller: _currentPageController,
              decoration: const InputDecoration(
                labelText: 'Página actual',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book_outlined),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                  return 'Introduce un número válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _favoriteQuotesController,
              decoration: const InputDecoration(
                labelText: 'Citas favoritas',
                hintText: 'Guarda frases memorables aquí...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              minLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _personalNotesController,
              decoration: const InputDecoration(
                labelText: 'Notas personales',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              minLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}