import 'package:between_pages/providers/journal/book_journal_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class JournalPage extends ConsumerWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Journal',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          backgroundColor: colorScheme.surface,
          bottom: TabBar(
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            tabs: const [
              Tab(text: 'Libros'),
              Tab(text: 'Mangas'),
              Tab(text: 'Fanfics'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Pestaña 1: Libros con portadas
            _BooksGridTab(),

            // Pestaña 2 y 3: Placeholders temporales
            Center(child: Text('Tus mangas (Próximamente)')),
            Center(child: Text('Tus fanfics (Próximamente)')),
          ],
        ),
      ),
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
