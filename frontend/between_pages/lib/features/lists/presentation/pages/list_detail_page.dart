import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:between_pages/features/lists/domain/list_response_dto.dart';

class ListDetailPage extends ConsumerWidget {
  final ListResponseDTO list;

  const ListDetailPage({super.key, required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(list.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función de editar lista próximamente')),
              );
            }, // TODO: Edit list
          ),
        ],
      ),
      body: Column(
        children: [
          if (list.description != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: colorScheme.surfaceContainerHighest,
              child: Text(
                list.description!,
                style: textTheme.bodyLarge,
              ),
            ),
          ],
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 1, // MVP: Mostrar texto explicativo
              itemBuilder: (context, index) => Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Text(
                    'Tu lista está vacía.\nAñade contenido desde el catálogo.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Añadir contenido a la lista próximamente')),
          );
        }, // TODO: Add item to list
        child: const Icon(Icons.add),
      ),
    );
  }
}
