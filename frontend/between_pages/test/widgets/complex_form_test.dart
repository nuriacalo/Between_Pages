import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Complex Form Widget Tests', () {
    testWidgets('Formulario con validación requerida', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      String? nameValue;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Requerido' : null,
                    onSaved: (value) => nameValue = value,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Validar campo vacío
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Requerido' : null,
                    onSaved: (value) => nameValue = value,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      
      expect(find.text('Requerido'), findsOneWidget);
    });

    testWidgets('Lista con múltiples items', (WidgetTester tester) async {
      const items = ['Libro 1', 'Libro 2', 'Libro 3'];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(items[index]));
              },
            ),
          ),
        ),
      );

      expect(find.byType(ListTile), findsWidgets);
      expect(find.text('Libro 1'), findsOneWidget);
      expect(find.text('Libro 2'), findsOneWidget);
      expect(find.text('Libro 3'), findsOneWidget);
    });

    testWidgets('TextFormField actualiza valor correctamente', 
        (WidgetTester tester) async {
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFormField(controller: controller),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Test text');
      expect(controller.text, equals('Test text'));
    });

    testWidgets('Dropdown selecciona valor', (WidgetTester tester) async {
      String? selectedValue;
      const items = ['Opción 1', 'Opción 2', 'Opción 3'];
      
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              body: DropdownButton<String>(
                value: selectedValue ?? items[0],
                items: items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => selectedValue = value),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      
      expect(find.text('Opción 1'), findsWidgets);
    });
  });
}
