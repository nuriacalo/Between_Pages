import 'package:flutter_test/flutter_test.dart';
import 'package:between_pages/features/notes/domain/note_dto.dart';

void main() {
  group('NoteDTO - Serialization', () {
    final noteJson = {
      'id': 1,
      'itemType': 'book',
      'itemId': 42,
      'quote': 'This is a quote from the book',
      'note': 'My thoughts about this',
      'page': 150,
      'createdAt': '2026-05-25T10:30:00Z',
    };

    test('deserializa correctamente desde JSON', () {
      final note = NoteDTO.fromJson(noteJson);

      expect(note.id, equals(1));
      expect(note.itemType, equals('book'));
      expect(note.itemId, equals(42));
      expect(note.quote, equals('This is a quote from the book'));
      expect(note.note, equals('My thoughts about this'));
      expect(note.page, equals(150));
      expect(note.createdAt, isNotNull);
    });

    test('serializa correctamente a JSON', () {
      final note = NoteDTO.fromJson(noteJson);
      final json = note.toJson();

      expect(json['id'], equals(1));
      expect(json['itemType'], equals('book'));
      expect(json['itemId'], equals(42));
      expect(json['quote'], equals('This is a quote from the book'));
      expect(json['note'], equals('My thoughts about this'));
    });

    test('maneja diferentes tipos de items', () {
      final types = ['book', 'manga', 'fanfiction'];
      
      for (final type in types) {
        final json = {
          'id': 1,
          'itemType': type,
          'itemId': 1,
          'quote': 'Test quote',
          'createdAt': '2026-05-25T10:30:00Z',
        };
        
        final note = NoteDTO.fromJson(json);
        expect(note.itemType, equals(type));
      }
    });

    test('maneja campos nulos correctamente', () {
      final minimalJson = {
        'itemType': 'book',
        'itemId': 1,
      };

      final note = NoteDTO.fromJson(minimalJson);
      expect(note.id, isNull);
      expect(note.quote, isNull);
      expect(note.note, isNull);
      expect(note.page, isNull);
    });
  });
}
