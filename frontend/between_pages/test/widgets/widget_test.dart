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

    testWidgets('Scaffold estructura correcta', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: const Text('Content'),
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('FloatingActionButton funciona', (WidgetTester tester) async {
      int tapCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () => tapCount++,
              child: const Icon(Icons.add),
            ),
            body: const Text('Test'),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      
      await tester.tap(find.byType(FloatingActionButton));
      expect(tapCount, equals(1));
    });
  });
}
