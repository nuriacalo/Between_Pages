import 'package:between_pages/providers/book_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: colorScheme.surface,
            child: TabBar(
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              dividerColor: colorScheme.outlineVariant.withAlpha(50),
              tabs: const [
                Tab(icon: Icon(Icons.book), text: 'Libros'),
                Tab(icon: Icon(Icons.menu_book), text: 'Mangas'),
                Tab(icon: Icon(Icons.article), text: 'Fanfics'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _BooksTab(),
                _MangasTab(),
                _FanficsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BooksTab extends ConsumerWidget {
  const _BooksTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el proveedor que trae la lista de libros del backend
    final booksAsync = ref.watch(bookProvider);

    return booksAsync.when(
      data: (books) {
        if (books.isEmpty) {
          return const Center(child: Text('No hay libros en tu Journal.'));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              clipBehavior: Clip.antiAlias,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  // Navegamos a los detalles pasándole el objeto libro completo
                  context.push('/book/${book.idBook}', extra: book);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Portada del libro (Estilo Póster de Serie)
                    SizedBox(
                      width: 100,
                      height: 150,
                      child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: book.coverUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.book,
                                size: 40,
                              ),
                            )
                          : Container(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.book, size: 40),
                            ),
                    ),
                    // Detalles del libro
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book.author,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            // Etiqueta del Género (Como las categorías de TV)
                            if (book.genre != null && book.genre!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  book.genre!,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Icono indicador de acción (Opcional, da feedback visual)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
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

class _MangasTab extends ConsumerWidget {
  const _MangasTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(child: Text('Tus Mangas aparecerán aquí.'));
  }
}

class _FanficsTab extends ConsumerWidget {
  const _FanficsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(child: Text('Tus Fanfics aparecerán aquí.'));
  }
}