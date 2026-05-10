import 'package:between_pages/core/api/api_client.dart';
import 'package:between_pages/features/auth/application/providers/api_provider.dart';
import 'package:between_pages/features/notes/domain/note_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class NoteRepository {
  Future<List<NoteDTO>> getEntries(int bookId);
  Future<NoteDTO> addEntry(NoteDTO entry);
  Future<void> deleteEntry(int entryId);
}

class NoteRepositoryImpl implements NoteRepository {
  final ApiClient _client;

  NoteRepositoryImpl(this._client);

  @override
  Future<List<NoteDTO>> getEntries(int bookId) async {
    final response = await _client.get('/notes?bookId=$bookId');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => NoteDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<NoteDTO> addEntry(NoteDTO entry) async {
    final response = await _client.post(
      '/notes',
      data: entry.toJson(),
    );
    return NoteDTO.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteEntry(int entryId) async {
    await _client.delete('/notes/$entryId');
  }
}

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return NoteRepositoryImpl(client);
});