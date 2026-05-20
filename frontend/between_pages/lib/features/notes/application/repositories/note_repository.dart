import 'package:between_pages/core/api/api_client.dart';
import 'package:between_pages/features/auth/application/providers/api_provider.dart';
import 'package:between_pages/features/notes/domain/note_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteRepository {
  final ApiClient _apiClient;

  NoteRepository(this._apiClient);

  Future<List<NoteDTO>> getNotes(String itemType, int itemId) async {
    final response = await _apiClient.get('/notes', queryParameters: {
      'itemType': itemType,
      'itemId': itemId,
    });
    return (response.data as List).map((e) => NoteDTO.fromJson(e)).toList();
  }

  Future<void> addNote(NoteDTO note) async {
    await _apiClient.post('/notes', data: note.toJson());
  }

  Future<void> deleteNote(int noteId) async {
    await _apiClient.delete('/notes/$noteId');
  }
}

final noteRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NoteRepository(apiClient);
});