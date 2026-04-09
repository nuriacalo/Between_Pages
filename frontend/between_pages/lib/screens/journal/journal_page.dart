import 'package:between_pages/providers/book_journal_provider.dart';
import 'package:between_pages/providers/list_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class JournalPage extends ConsumerWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Libros'),
              Tab(text: 'Mangas'),
              Tab(text: 'Fanfics'),
              Tab(text: 'Listas'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Pestaña 1: Libros con portadas
                const _BooksGridTab(),

                // Pestaña 2, 3 y 4: Placeholders temporales
                const Center(child: Text('Tus mangas (Próximamente)')),
                const Center(child: Text('Tus fanfics (Próximamente)')),
                const _ListsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListsTab extends ConsumerWidget {
  const _ListsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el proveedor que trae las listas del backend
    final listsAsync = ref.watch(listProvider);

    return listsAsync.when(
      data: (lists) {
        if (lists.isEmpty) {
          return const Center(child: Text('No tienes listas creadas aún.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lists.length,
          itemBuilder: (context, index) {
            final list = lists[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.list),
                title: Text(list.name),
                subtitle: Text('${list.items.length} elementos guardados'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navegar a la pantalla de detalles de la lista para ver las portadas
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _BooksGridTab extends ConsumerWidget {
  const _BooksGridTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el proveedor que trae la lista de libros del backend
    final journalsAsync = ref.watch(bookJournalProvider);

    return journalsAsync.when(
      data: (journals) {
        if (journals.isEmpty) {
          return const Center(child: Text('No hay libros en tu Journal.'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 portadas por fila
            childAspectRatio: 0.65, // Proporción de portada de libro
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
          ),
          itemCount: journals.length,
          itemBuilder: (context, index) {
            final journal = journals[index];
            final book = journal.book;

            return InkWell(
              onTap: () => context.push('/book/${book.idBook}', extra: book),
              borderRadius: BorderRadius.circular(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: book.coverUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.book, size: 40),
                              ),
                            )
                          : Container(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.book, size: 40),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
