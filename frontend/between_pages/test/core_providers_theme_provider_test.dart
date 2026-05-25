import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:between_pages/core/providers/theme_provider.dart';

void main() {
  group('ThemeNotifier', () {
    late ThemeNotifier themeNotifier;

    setUp(() {
      themeNotifier = ThemeNotifier();
    });

    test('inicializa con tema claro por defecto', () {
      expect(themeNotifier.state, equals(ThemeMode.light));
      expect(themeNotifier.isDark, isFalse);
    });

    test('isDark retorna false cuando el tema es claro', () {
      themeNotifier = ThemeNotifier();
      expect(themeNotifier.isDark, isFalse);
    });

    test('isDark retorna true cuando el tema es oscuro', () async {
      themeNotifier = ThemeNotifier();
      await themeNotifier.toggle();
      expect(themeNotifier.isDark, isTrue);
    });

    test('toggle cambia de tema claro a oscuro', () async {
      expect(themeNotifier.state, equals(ThemeMode.light));
      await themeNotifier.toggle();
      expect(themeNotifier.state, equals(ThemeMode.dark));
    });

    test('toggle cambia de tema oscuro a claro', () async {
      await themeNotifier.toggle();
      expect(themeNotifier.state, equals(ThemeMode.dark));
      await themeNotifier.toggle();
      expect(themeNotifier.state, equals(ThemeMode.light));
    });

    test('múltiples toggles funcionan correctamente', () async {
      expect(themeNotifier.state, equals(ThemeMode.light));

      await themeNotifier.toggle();
      expect(themeNotifier.state, equals(ThemeMode.dark));

      await themeNotifier.toggle();
      expect(themeNotifier.state, equals(ThemeMode.light));

      await themeNotifier.toggle();
      expect(themeNotifier.state, equals(ThemeMode.dark));
    });
  });
}
