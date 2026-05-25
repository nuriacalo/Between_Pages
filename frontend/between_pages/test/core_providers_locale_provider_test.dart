import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:between_pages/core/providers/locale_provider.dart';

void main() {
  group('LocaleNotifier', () {
    late LocaleNotifier localeNotifier;

    setUp(() {
      localeNotifier = LocaleNotifier();
    });

    test('inicializa con localidad española por defecto', () {
      expect(localeNotifier.state, equals(const Locale('es')));
    });

    test('cambia a localidad inglesa', () {
      localeNotifier.setLocale(const Locale('en'));
      expect(localeNotifier.state, equals(const Locale('en')));
    });

    test('cambia a localidad gallega', () {
      localeNotifier.setLocale(const Locale('gl'));
      expect(localeNotifier.state, equals(const Locale('gl')));
    });

    test('puede cambiar múltiples veces entre localidades', () {
      localeNotifier.setLocale(const Locale('en'));
      expect(localeNotifier.state, equals(const Locale('en')));

      localeNotifier.setLocale(const Locale('gl'));
      expect(localeNotifier.state, equals(const Locale('gl')));

      localeNotifier.setLocale(const Locale('es'));
      expect(localeNotifier.state, equals(const Locale('es')));
    });
  });
}
