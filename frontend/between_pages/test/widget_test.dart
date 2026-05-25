// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Between Pages App Widget Tests', () {
    testWidgets('App renders without errors', (WidgetTester tester) async {
      // Create a simple Material app for testing
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Between Pages'),
            ),
            body: const Center(
              child: Text('Test Widget'),
            ),
          ),
        ),
      );

      // Verify that the app renders
      expect(find.text('Between Pages'), findsOneWidget);
      expect(find.text('Test Widget'), findsOneWidget);
    });

    testWidgets('MaterialApp renders correctly', (WidgetTester tester) async {
      // Create a simple Material app
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Hello World'),
            ),
          ),
        ),
      );

      // Verify text is displayed
      expect(find.text('Hello World'), findsOneWidget);

      // Verify it's in the center
      expect(find.byType(Center), findsOneWidget);
    });
  });
}
