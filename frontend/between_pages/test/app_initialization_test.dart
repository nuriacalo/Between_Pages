import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('App Initialization Tests', () {
    test('Locale es válida', () {
      const locale = Locale('es');
      expect(locale.languageCode, equals('es'));
    });

    test('ThemeMode values existen', () {
      expect(ThemeMode.light, isNotNull);
      expect(ThemeMode.dark, isNotNull);
      expect(ThemeMode.system, isNotNull);
    });

    test('Color scheme se puede crear', () {
      final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);
      expect(colorScheme, isNotNull);
      expect(colorScheme.primary, isNotNull);
    });

    test('Material 3 features disponibles', () {
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      );
      expect(theme.useMaterial3, isTrue);
    });
  });
}
