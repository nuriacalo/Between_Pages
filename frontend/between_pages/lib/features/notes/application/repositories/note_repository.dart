import 'package:between_pages/core/api/api_client.dart';
import 'package:between_pages/features/auth/application/providers/api_provider.dart';
import 'package:between_pages/features/notes/domain/note_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NoteRepository
// ─────────────────────────────────────────────────────────────────────────────

class NoteRepository {
  final ApiClient _apiClient;
  const NoteRepository(this._apiClient);

  /// Fetches all notes for a given item.
  Future<List<NoteDTO>> getNotes(String itemType, int itemId) async {
    final response = await _apiClient.get(
      '/notes',
      queryParameters: {
        'itemType': itemType,
        'itemId':   itemId,
      },
    );
    return (response.data as List)
        .map((e) => NoteDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches all global notes for the current user.
  Future<List<NoteDTO>> getAllNotes() async {
    final response = await _apiClient.get('/notes/all');
    return (response.data as List)
        .map((e) => NoteDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Creates a new note. The backend assigns the id.
  Future<NoteDTO> addNote(NoteDTO note) async {
    final response = await _apiClient.post('/notes', data: note.toJson());
    // Return the created note (with the backend-assigned id and createdAt).
    return NoteDTO.fromJson(response.data as Map<String, dynamic>);
  }

  /// Updates an existing note. Requires [note.id] to be non-null.
  Future<NoteDTO> updateNote(NoteDTO note) async {
    assert(note.id != null, 'updateNote requires a note with a valid id');
    final response = await _apiClient.put(
      '/notes/${note.id}',
      data: note.toJson(),
    );
    return NoteDTO.fromJson(response.data as Map<String, dynamic>);
  }

  /// Deletes a note by id.
  Future<void> deleteNote(int noteId) async {
    await _apiClient.delete('/notes/$noteId');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  // ref.watch: if apiClientProvider rebuilds (re-auth, token refresh),
  // the repository is also rebuilt with the new client.
  final apiClient = ref.watch(apiClientProvider);
  return NoteRepository(apiClient);
});