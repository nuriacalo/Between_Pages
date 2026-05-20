import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:between_pages/features/lists/domain/list_response_dto.dart';

class ListDetailPage extends ConsumerStatefulWidget {
  final ListResponseDTO list;

  const ListDetailPage({super.key, required this.list});

  @override
  ConsumerState<ListDetailPage> createState() => _ListDetailPageState();
}

class _ListDetailPageState extends ConsumerState<ListDetailPage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.list.name),
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
          if (widget.list.description != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: colorScheme.surfaceContainerHighest,
              child: Text(
                widget.list.description!,
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
          context.push('/list/${widget.list.id}/add-content');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
