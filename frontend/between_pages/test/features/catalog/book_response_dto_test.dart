import 'package:flutter_test/flutter_test.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';

void main() {
  group('BookResponseDTO - Serialization', () {
    final bookJson = {
      'id': 1,
      'google_books_id': 'google123',
      'title': 'Test Book',
      'author': 'Test Author',
      'isbn': '1234567890',
      'publisher': 'Test Publisher',
      'description': 'A test book',
      'cover_url': 'https://example.com/cover.jpg',
      'genres': ['Fiction', 'Adventure'],
      'book_type': 'Paperback',
      'publication_year': 2023,
      'page_count': 300,
    };

    test('deserializa correctamente desde JSON', () {
      final book = BookResponseDTO.fromJson(bookJson);

      expect(book.idBook, equals(1));
      expect(book.title, equals('Test Book'));
      expect(book.author, equals('Test Author'));
      expect(book.isbn, equals('1234567890'));
      expect(book.publisher, equals('Test Publisher'));
      expect(book.googleBooksId, equals('google123'));
      expect(book.coverUrl, equals('https://example.com/cover.jpg'));
      expect(book.genres, equals(['Fiction', 'Adventure']));
      expect(book.pageCount, equals(300));
    });

    test('serializa correctamente a JSON', () {
      final book = BookResponseDTO.fromJson(bookJson);
      final json = book.toJson();

      expect(json['id'], equals(1));
      expect(json['title'], equals('Test Book'));
      expect(json['author'], equals('Test Author'));
      expect(json['isbn'], equals('1234567890'));
    });

    test('maneja valores nulos correctamente', () {
      final minimalJson = {
        'id': 2,
        'title': 'Minimal Book',
        'author': 'Author',
        'genres': [],
      };

      final book = BookResponseDTO.fromJson(minimalJson);
      expect(book.idBook, equals(2));
      expect(book.googleBooksId, isNull);
      expect(book.coverUrl, isNull);
      expect(book.genres, isEmpty);
    });

    test('implementa MediaItem correctamente', () {
      final book = BookResponseDTO.fromJson(bookJson);
      
      expect(book.title, equals('Test Book'));
      expect(book.author, equals('Test Author'));
    });
  });
}
