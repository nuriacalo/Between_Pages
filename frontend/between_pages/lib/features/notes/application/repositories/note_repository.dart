import 'package:between_pages/features/notes/domain/note_dto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteRepository {
  final Dio _dio;

  NoteRepository(this._dio);

  Future<List<NoteDTO>> getNotes(String itemType, int itemId) async {
    final response = await _dio.get('/notes', queryParameters: {
      'itemType': itemType,
      'itemId': itemId,
    });
    return (response.data as List).map((e) => NoteDTO.fromJson(e)).toList();
  }

  Future<void> addNote(NoteDTO note) async {
    await _dio.post('/notes', data: note.toJson());
  }

  Future<void> deleteNote(int noteId) async {
    await _dio.delete('/notes/$noteId');
  }
}

final noteRepositoryProvider = Provider((ref) {
  // This will be replaced by the actual Dio provider
  return NoteRepository(Dio());
});