import 'package:between_pages/features/notes/application/repositories/note_repository.dart';
import 'package:between_pages/features/notes/domain/note_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// notesProvider
//
// Fetches the list of notes for a given (itemType, itemId) pair.
// autoDispose: the cache is discarded when no widget is watching,
// keeping memory clean when navigating away from the notes page.
// ─────────────────────────────────────────────────────────────────────────────

final notesProvider = FutureProvider.autoDispose
    .family<List<NoteDTO>, ({String itemType, int itemId})>(
  (ref, ids) {
    // ref.watch is correct here — if noteRepositoryProvider ever rebuilds
    // (e.g. after re-authentication), this provider rebuilds too.
    final repo = ref.watch(noteRepositoryProvider);
    return repo.getNotes(ids.itemType, ids.itemId);
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// noteNotifierProvider
//
// Handles mutations: add, update, delete.
// Uses AsyncNotifier (Riverpod 2.x) instead of the deprecated StateNotifier.
//
// Usage in a widget:
//   ref.read(noteNotifierProvider.notifier).addEntry(note);
//
// To react to loading / error state in the UI:
//   final state = ref.watch(noteNotifierProvider);
//   state.when(data: (_) {}, loading: () {}, error: (e, _) {});
// ─────────────────────────────────────────────────────────────────────────────

final noteNotifierProvider =
    AsyncNotifierProvider<NoteNotifier, void>(NoteNotifier.new);

class NoteNotifier extends AsyncNotifier<void> {
  // build() is required by AsyncNotifier. We have no initial async work,
  // so it returns immediately.
  @override
  Future<void> build() async {}

  NoteRepository get _repo => ref.read(noteRepositoryProvider);

  // ── Add ──────────────────────────────────────────────────────────────────

  Future<void> addEntry(NoteDTO note) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.addNote(note);
      // Invalidate the list so the UI refreshes automatically.
      ref.invalidate(
        notesProvider((itemType: note.itemType, itemId: note.itemId)),
      );
    });
  }

  // ── Update ───────────────────────────────────────────────────────────────

  Future<void> updateEntry(NoteDTO note) async {
    assert(note.id != null, 'updateEntry requires a note with a valid id');
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.updateNote(note);
      ref.invalidate(
        notesProvider((itemType: note.itemType, itemId: note.itemId)),
      );
    });
  }

  // ── Delete ───────────────────────────────────────────────────────────────

  Future<void> deleteEntry(
    int    noteId,
    String itemType,
    int    itemId,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.deleteNote(noteId);
      ref.invalidate(notesProvider((itemType: itemType, itemId: itemId)));
    });
  }
}