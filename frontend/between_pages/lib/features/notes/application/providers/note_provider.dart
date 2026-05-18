import 'package:between_pages/features/notes/application/repositories/note_repository.dart';
import 'package:between_pages/features/notes/domain/note_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notesProvider = FutureProvider.autoDispose.family<List<NoteDTO>, ({String itemType, int itemId})>((ref, ids) {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.getNotes(ids.itemType, ids.itemId);
});

final noteNotifierProvider = StateNotifierProvider<NoteNotifier, AsyncValue<void>>((ref) {
  return NoteNotifier(ref.watch(noteRepositoryProvider), ref);
});

class NoteNotifier extends StateNotifier<AsyncValue<void>> {
  final NoteRepository _repo;
  final Ref _ref;

  NoteNotifier(this._repo, this._ref) : super(const AsyncData(null));

  Future<void> addEntry(NoteDTO note) async {
    state = const AsyncLoading();
    try {
      await _repo.addNote(note);
      _ref.invalidate(notesProvider((itemType: note.itemType, itemId: note.itemId)));
      state = const AsyncData(null);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<void> deleteEntry(int noteId, String itemType, int itemId) async {
    state = const AsyncLoading();
    try {
      await _repo.deleteNote(noteId);
      _ref.invalidate(notesProvider((itemType: itemType, itemId: itemId)));
      state = const AsyncData(null);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }
}