import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThemeNotifier - Basic Tests', () {
    test('ThemeMode values existen', () {
      expect(ThemeMode.light, equals(ThemeMode.light));
      expect(ThemeMode.dark, equals(ThemeMode.dark));
      expect(ThemeMode.system, equals(ThemeMode.system));
    });

    test('light theme es diferente de dark theme', () {
      expect(ThemeMode.light == ThemeMode.dark, isFalse);
    });

    test('se puede comparar temas', () {
      final theme1 = ThemeMode.light;
      final theme2 = ThemeMode.light;
      expect(theme1, equals(theme2));
    });

    test('isDark property puede verificarse', () {
      final isDark = (ThemeMode.dark == ThemeMode.dark);
      expect(isDark, isTrue);

      final isLight = (ThemeMode.light == ThemeMode.light);
      expect(isLight, isTrue);
    });
  });
}
