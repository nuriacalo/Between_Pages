import 'package:between_pages/features/notes/application/repository/note_repository.dart';
import 'package:between_pages/features/notes/domain/note_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Carga las notas de un libro concreto
final notesProvider = FutureProvider.family<List<NoteDTO>, int>(
  (ref, bookId) async {
    final repo = ref.watch(noteRepositoryProvider);
    return repo.getEntries(bookId);
  },
);

// Notifier para añadir y borrar con invalidación automática
class NoteNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addEntry(NoteDTO entry) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.addEntry(entry);
    ref.invalidate(notesProvider(entry.bookId));
  }

  Future<void> deleteEntry(int entryId, int bookId) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.deleteEntry(entryId);
    ref.invalidate(notesProvider(bookId));
  }
}

final noteNotifierProvider =
    AsyncNotifierProvider<NoteNotifier, void>(NoteNotifier.new);