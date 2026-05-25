import 'package:flutter_test/flutter_test.dart';
import 'package:between_pages/features/lists/domain/list_response_dto.dart';

void main() {
  group('ListResponseDTO - Serialization', () {
    final listJson = {
      'id': '123',
      'name': 'My Reading List',
      'description': 'A list of books to read',
    };

    test('deserializa correctamente desde JSON', () {
      final list = ListResponseDTO.fromJson(listJson);

      expect(list.id, equals(123));
      expect(list.name, equals('My Reading List'));
      expect(list.description, equals('A list of books to read'));
    });

    test('serializa correctamente a JSON', () {
      final list = ListResponseDTO.fromJson(listJson);
      final json = list.toJson();

      expect(json['id'], equals(123));
      expect(json['name'], equals('My Reading List'));
      expect(json['description'], equals('A list of books to read'));
    });

    test('convierte string id a int correctamente', () {
      final json = {
        'id': '456',
        'name': 'Test List',
      };

      final list = ListResponseDTO.fromJson(json);
      expect(list.id, equals(456));
      expect(list.id, isA<int>());
    });

    test('maneja valores nulos en descripción', () {
      final json = {
        'id': '789',
        'name': 'List without description',
        'description': null,
      };

      final list = ListResponseDTO.fromJson(json);
      expect(list.description, isNull);
    });

    test('maneja IDs numéricos directos', () {
      final json = {
        'id': 999,
        'name': 'Numeric ID List',
      };

      final list = ListResponseDTO.fromJson(json);
      expect(list.id, equals(999));
    });
  });
}
