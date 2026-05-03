import 'package:between_pages/providers/user/user_provider.dart';
import 'package:between_pages/providers/lists/reading_list_provider.dart';
import 'package:between_pages/repositories/reading_list_repository.dart';
import 'package:between_pages/models/lists/reading_list_request_dto.dart';
import 'package:between_pages/widgets/common/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadingListsPage extends ConsumerWidget {
  const ReadingListsPage({super.key});

  void _showCreateListDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Colección'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la lista',
                hintText: 'Ej: Favoritos de Fantasía',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Descripción (Opcional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              final repo = ref.read(readingListRepositoryProvider);
              final user = await ref.read(userProfileProvider.future);

              await repo.createList(
                user.idUser,
                ReadingListRequestDTO(
                  name: nameController.text.trim(),
                  description: descController.text.trim().isNotEmpty
                      ? descController.text.trim()
                      : null,
                ),
              );

              ref.invalidate(userReadingListsProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(userReadingListsProvider);
    final accentColor = const Color(0xFFA87C80);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Colecciones')),
      body: listsAsync.when(
        data: (lists) {
          if (lists.isEmpty) {
            return const EmptyState(
              icon: Icons.collections_bookmark_outlined,
              title: 'Aún no tienes colecciones',
              subtitle: 'Crea carpetas para organizar tus lecturas favoritas',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final list = lists[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    Icons.folder_special,
                    size: 40,
                    color: accentColor,
                  ),
                  title: Text(
                    list.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: list.description != null
                      ? Text(list.description!)
                      : null,
                  onTap: () {
                    // TODO: Módulo 2 - Navegar al detalle de la lista para ver los libros dentro
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateListDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Colección'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
