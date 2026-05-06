import 'package:between_pages/providers/lists/list_provider.dart';
import 'package:between_pages/providers/user/user_provider.dart';
import 'package:between_pages/repositories/reading_list_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'list_detail_page.dart';

class ReadingListsPage extends ConsumerStatefulWidget {
  const ReadingListsPage({super.key});

  @override
  ConsumerState<ReadingListsPage> createState() => _ReadingListsPageState();
}

class _ReadingListsPageState extends ConsumerState<ReadingListsPage> {
  final _formKey = GlobalKey<FormState>();

  void _showCreateListDialog(BuildContext context, WidgetRef ref) {
    final repo = ref.read(readingListRepositoryProvider);
    final userProfile = ref.read(userProfileProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear nueva lista'),
        content: StatefulBuilder(
          builder: (context, setState) => Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                  onSaved: (value) {},
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
                  maxLines: 2,
                  onSaved: (value) {},
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                Navigator.pop(context);
                // Placeholder - full impl with TextEditingController needed
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lista creada (demo)')),
                );
                ref.invalidate(listProvider);
              }
            },
            child: const Text('Crear'),

          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final textTheme = Theme.of(context).textTheme;
final listsAsync = ref.watch(listProvider);


    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mis Listas',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.surface,
      ),
      body: listsAsync.when(
        data: (lists) {
          if (lists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.list_alt,
                    size: 64,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes listas creadas',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu primera lista de lectura',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateListDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear lista'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lists.length + 1, // +1 para el botón de crear al final
            itemBuilder: (context, index) {
              if (index == lists.length) {
                // Último elemento: botón para crear nueva lista
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: OutlinedButton.icon(
                    onPressed: () => _showCreateListDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear nueva lista'),
                  ),
                );
              }

              final list = lists[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.list,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    list.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: list.description != null
                      ? Text(
                          list.description!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        )
                      : Text(
                          'Sin descripción',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ListDetailPage(list: list),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar listas',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(listProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
