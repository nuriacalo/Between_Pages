import 'package:between_pages/models/journal/book_journal_record_dto.dart';
import 'package:between_pages/models/journal/book_journal_response_dto.dart';
import 'package:between_pages/providers/journal/book_journal_provider.dart';
import 'package:between_pages/providers/user/user_provider.dart';
import 'package:between_pages/repositories/book_journal_repository.dart';
import 'package:between_pages/repositories/journal_status_helper.dart';
import 'package:between_pages/widgets/journal/journal_edit_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BookJournalEditPage extends ConsumerWidget {
  final BookJournalResponseDto journal;

  const BookJournalEditPage({super.key, required this.journal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return JournalEditForm<BookJournalResponseDto, BookJournalRecordDTO,
        BookJournalRepository>(
      journal: journal,
      repositoryProvider: bookJournalRepositoryProvider,
      recordDtoBuilder: (oldJournal, updatedValues) {
        final book = oldJournal.book;
        final userId = ref.read(userProfileProvider).value!.idUser;

        return BookJournalRecordDTO(
          userId: userId,
          bookId: book.idBook,
          googleBooksId: book.googleBooksId,
          status: updatedValues['status'] as String,
          rating: updatedValues['rating'] as int?,
          tearDrops: updatedValues['tearDrops'] as int?,
          spiceFlames: updatedValues['spiceFlames'] as int?,
          personalNotes: updatedValues['personalNotes'] as String?,
          startDate: oldJournal.startDate,
          endDate: updatedValues['endDate'] as String?,
          ownership: updatedValues['ownership'] as String?,
          rereading: oldJournal.rereading,
          currentPage: int.tryParse(updatedValues['currentPage'] ?? '') ??
              oldJournal.currentPage,
          favoriteQuotes: updatedValues['favoriteQuotes'] as String?,
          seriesName: updatedValues['seriesName'] as String?,
          seriesOrder: updatedValues['seriesOrder'] != null &&
                  (updatedValues['seriesOrder'] as String).isNotEmpty
              ? double.tryParse(updatedValues['seriesOrder'])
              : null,
          loanedTo: updatedValues['loanedTo'] as String?,
        );
      },
      specificFieldsBuilder: (currentJournal, controllers) {
        // Initialize controllers if they don't exist
        controllers.putIfAbsent(
            'currentPage',
            () => TextEditingController(
                text: currentJournal.currentPage?.toString() ?? ''));
        controllers.putIfAbsent(
            'favoriteQuotes',
            () => TextEditingController(
                text: currentJournal.favoriteQuotes ?? ''));
        controllers.putIfAbsent(
            'seriesName',
            () => TextEditingController(
                text: currentJournal.seriesName ?? ''));
        controllers.putIfAbsent(
            'seriesOrder',
            () => TextEditingController(
                text: currentJournal.seriesOrder?.toString() ?? ''));
        controllers.putIfAbsent(
            'loanedTo',
            () => TextEditingController(
                text: currentJournal.loanedTo ?? ''));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Módulo 2: Organización ---
            Text(
              'Organización',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 20),
            TextFormField(
              controller: controllers['seriesName'],
              decoration: const InputDecoration(
                labelText: 'Nombre de la Saga/Serie',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.collections_bookmark_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['seriesOrder'],
              decoration: const InputDecoration(
                labelText: 'Orden en la saga (ej: 1, 1.5, 2)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.format_list_numbered),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['loanedTo'],
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
                Text(
                  'El Segundo Cerebro',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.document_scanner_outlined),
                  tooltip: 'Escanear texto (OCR)',
                  onPressed: () async {
                    final scannedText = await context.push<String>(
                      '/ocr-scanner',
                    );
                    if (scannedText != null && scannedText.isNotEmpty) {
                      controllers['favoriteQuotes']?.text =
                          '${controllers['favoriteQuotes']?.text.trim() ?? ''}\n\n$scannedText';
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Texto extraído y añadido con éxito'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const Divider(height: 16),
            TextFormField(
              controller: controllers['currentPage'],
              decoration: const InputDecoration(
                labelText: 'Página actual',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book_outlined),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null &&
                    value.isNotEmpty &&
                    int.tryParse(value) == null) {
                  return 'Introduce un número válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controllers['favoriteQuotes'],
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
          ],
        );
      },
      onSave: (ref) {
        ref.invalidate(bookJournalProvider);
        ref.invalidate(bookJournalEntryProvider(journal.book.idBook));
        // Si se marcó como terminado, abrir la pantalla inmersiva del Diario
        final dbStatus = JournalStatusHelper.mapStatusToDb(journal.status ?? 'TBR');
        if (dbStatus == 'FINISHED' && journal.status != 'FINISHED') {
          context.push('/journal/book/diary', extra: journal);
        }
      },
    );
  }
}
