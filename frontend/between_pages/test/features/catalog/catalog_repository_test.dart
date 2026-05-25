import 'package:flutter_test/flutter_test.dart';
import 'package:between_pages/core/api/api_client.dart';
import 'package:between_pages/core/api/auth_token_storage.dart';
import 'package:between_pages/features/catalog/application/repositories/catalog_repository.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';

void main() {
  group('CatalogRepository - Initialization', () {
    test('inicializa correctamente con ApiClient', () {
      final tokenStorage = AuthTokenStorage();
      final apiClient = ApiClient(
        baseUrl: 'http://example.com/api',
        tokenStorage: tokenStorage,
      );
      final catalogRepository = CatalogRepository(apiClient);

      expect(catalogRepository, isNotNull);
      expect(catalogRepository, isA<CatalogRepository>());
    });
  });

  group('CatalogRepository - Methods Available', () {
    test('tiene método getAllBooks', () {
      final tokenStorage = AuthTokenStorage();
      final apiClient = ApiClient(
        baseUrl: 'http://example.com/api',
        tokenStorage: tokenStorage,
      );
      final catalogRepository = CatalogRepository(apiClient);

      expect(catalogRepository.getAllBooks, isA<Function>());
    });

    test('tiene método getAllManga', () {
      final tokenStorage = AuthTokenStorage();
      final apiClient = ApiClient(
        baseUrl: 'http://example.com/api',
        tokenStorage: tokenStorage,
      );
      final catalogRepository = CatalogRepository(apiClient);

      expect(catalogRepository.getAllManga, isA<Function>());
    });

    test('tiene método getAllFanfics', () {
      final tokenStorage = AuthTokenStorage();
      final apiClient = ApiClient(
        baseUrl: 'http://example.com/api',
        tokenStorage: tokenStorage,
      );
      final catalogRepository = CatalogRepository(apiClient);

      expect(catalogRepository.getAllFanfics, isA<Function>());
    });

    test('tiene método saveOrUpdateManga', () {
      final tokenStorage = AuthTokenStorage();
      final apiClient = ApiClient(
        baseUrl: 'http://example.com/api',
        tokenStorage: tokenStorage,
      );
      final catalogRepository = CatalogRepository(apiClient);

      expect(catalogRepository.saveOrUpdateManga, isA<Function>());
    });
  });

  group('CatalogRepository - Data Mapping', () {
    test('BookResponseDTO se mapea correctamente', () {
      final bookJson = {
        'id': 1,
        'title': 'Test Book',
        'author': 'Author Name',
        'genres': ['Fiction'],
      };

      final book = BookResponseDTO.fromJson(bookJson);
      
      expect(book.title, equals('Test Book'));
      expect(book.author, equals('Author Name'));
      expect(book.genres, contains('Fiction'));
    });
  });
}
