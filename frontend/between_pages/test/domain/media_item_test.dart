import 'package:flutter_test/flutter_test.dart';
import 'package:between_pages/features/catalog/domain/media_item.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';

void main() {
  group('MediaItem Interface - Implementation', () {
    test('BookResponseDTO implementa MediaItem', () {
      final bookJson = {
        'id': 1,
        'title': 'Test Book',
        'author': 'Test Author',
        'genres': [],
      };
      
      final book = BookResponseDTO.fromJson(bookJson);
      expect(book, isA<MediaItem>());
      expect(book.title, isNotEmpty);
      expect(book.author, isNotEmpty);
    });

    test('MangaResponseDTO implementa MediaItem', () {
      final mangaJson = {
        'id': 1,
        'title': 'Test Manga',
        'author': 'Test Author',
        'genres': [],
      };
      
      final manga = MangaResponseDTO.fromJson(mangaJson);
      expect(manga, isA<MediaItem>());
      expect(manga.title, isNotEmpty);
      expect(manga.author, isNotEmpty);
    });

    test('FanfictionResponseDTO implementa MediaItem', () {
      final fanficJson = {
        'id': 1,
        'title': 'Test Fanfic',
        'author': 'Test Author',
        'genres': [],
      };
      
      final fanfic = FanfictionResponseDTO.fromJson(fanficJson);
      expect(fanfic, isA<MediaItem>());
      expect(fanfic.title, isNotEmpty);
      expect(fanfic.author, isNotEmpty);
    });

    test('MediaItems tienen propiedades consistentes', () {
      final bookJson = {
        'id': 1,
        'title': 'Book Title',
        'author': 'Book Author',
        'genres': [],
      };
      
      final mangaJson = {
        'id': 2,
        'title': 'Manga Title',
        'author': 'Manga Author',
        'genres': [],
      };

      final book = BookResponseDTO.fromJson(bookJson) as MediaItem;
      final manga = MangaResponseDTO.fromJson(mangaJson) as MediaItem;

      expect(book.title, equals('Book Title'));
      expect(manga.title, equals('Manga Title'));
    });
  });
}
