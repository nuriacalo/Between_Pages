import 'package:between_pages/providers/journal/book_journal_provider.dart';
import 'package:between_pages/widgets/common/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pantalla del "Segundo Cerebro": Centraliza todas las notas y citas del usuario.
class SecondBrainPage extends ConsumerWidget {
  const SecondBrainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos los journals de libros (se podría expandir a mangas y fanfics)
    final bookJournalsAsync = ref.watch(bookJournalProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Segundo Cerebro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implementar búsqueda en notas
            },
          ),
        ],
      ),
      body: bookJournalsAsync.when(
        data: (journals) {
          // Filtramos solo los journals que tienen notas o citas
          final notesAndQuotes = journals.where((j) =>
              (j.personalNotes != null && j.personalNotes!.isNotEmpty) ||
              (j.favoriteQuotes != null && j.favoriteQuotes!.isNotEmpty)).toList();

          if (notesAndQuotes.isEmpty) {
            return const EmptyState(
              icon: Icons.psychology_outlined,
              title: 'Tu Segundo Cerebro está vacío',
              subtitle: 'Añade citas y notas a tus lecturas para verlas aquí.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notesAndQuotes.length,
            itemBuilder: (context, index) {
              final journal = notesAndQuotes[index];
              final book = journal.book;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.book, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              book.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      if (journal.favoriteQuotes != null && journal.favoriteQuotes!.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.format_quote, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text('Citas Favoritas', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          journal.favoriteQuotes!,
                          style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (journal.personalNotes != null && journal.personalNotes!.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.notes, color: colorScheme.secondary),
                            const SizedBox(width: 8),
                            Text('Notas Personales', style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(journal.personalNotes!),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error al cargar notas: $err')),
      ),
    );
  }
}