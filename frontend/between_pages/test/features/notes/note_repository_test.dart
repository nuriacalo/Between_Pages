import 'package:flutter_test/flutter_test.dart';
import 'package:between_pages/core/api/api_client.dart';
import 'package:between_pages/core/api/auth_token_storage.dart';
import 'package:between_pages/features/notes/application/repositories/note_repository.dart';

void main() {
  group('NoteRepository - Initialization', () {
    test('inicializa correctamente con ApiClient', () {
      final tokenStorage = AuthTokenStorage();
      final apiClient = ApiClient(
        baseUrl: 'http://example.com/api',
        tokenStorage: tokenStorage,
      );
      final noteRepository = NoteRepository(apiClient);

      expect(noteRepository, isNotNull);
      expect(noteRepository, isA<NoteRepository>());
    });
  });

  group('NoteRepository - Methods Available', () {
    test('tiene método getNotes', () {
      final tokenStorage = AuthTokenStorage();
      final apiClient = ApiClient(
        baseUrl: 'http://example.com/api',
        tokenStorage: tokenStorage,
      );
      final noteRepository = NoteRepository(apiClient);

      expect(noteRepository.getNotes, isA<Function>());
    });

    test('tiene método getAllNotes', () {
      final tokenStorage = AuthTokenStorage();
      final apiClient = ApiClient(
        baseUrl: 'http://example.com/api',
        tokenStorage: tokenStorage,
      );
      final noteRepository = NoteRepository(apiClient);

      expect(noteRepository.getAllNotes, isA<Function>());
    });

    test('tiene método addNote', () {
      final tokenStorage = AuthTokenStorage();
      final apiClient = ApiClient(
        baseUrl: 'http://example.com/api',
        tokenStorage: tokenStorage,
      );
      final noteRepository = NoteRepository(apiClient);

      expect(noteRepository.addNote, isA<Function>());
    });

    test('tiene método updateNote', () {
      final tokenStorage = AuthTokenStorage();
      final apiClient = ApiClient(
        baseUrl: 'http://example.com/api',
        tokenStorage: tokenStorage,
      );
      final noteRepository = NoteRepository(apiClient);

      expect(noteRepository.updateNote, isA<Function>());
    });

    test('tiene método deleteNote', () {
      final tokenStorage = AuthTokenStorage();
      final apiClient = ApiClient(
        baseUrl: 'http://example.com/api',
        tokenStorage: tokenStorage,
      );
      final noteRepository = NoteRepository(apiClient);

      expect(noteRepository.deleteNote, isA<Function>());
    });
  });
}
