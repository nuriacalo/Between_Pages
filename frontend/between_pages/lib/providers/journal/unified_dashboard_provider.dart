import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:between_pages/providers/journal/book_journal_provider.dart';
import 'package:between_pages/providers/journal/manga_journal_provider.dart';
import 'package:between_pages/providers/journal/fanfic_journal_provider.dart';

/// Proveedor que unifica todas las lecturas actuales (Libros, Mangas, Fanfics)
/// para mostrarlas de forma mezclada.
final unifiedReadingDashboardProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  try {
    // Ya tenemos FutureProviders que cachean esta información, así que simplemente los leemos.
    final books = await ref.watch(bookJournalProvider.future);
    final mangas = await ref.watch(mangaJournalProvider.future);
    final fanfics = await ref.watch(fanficJournalProvider.future);

    // Filtramos solo los que están siendo leídos actualmente ('READING')
    final List<dynamic> combinedList = [
      ...books.where((b) => b.status == 'READING'),
      ...mangas.where((m) => m.status == 'READING'),
      ...fanfics.where((f) => f.status == 'READING'),
    ];
    
    // Opcionalmente podrías hacer un sort por fecha de actualización aquí

    return combinedList;
  } catch (e) {
    throw Exception('Error cargando el dashboard unificado: $e');
  }
});