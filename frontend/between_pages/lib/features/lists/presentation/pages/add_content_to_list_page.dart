import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/catalog/application/repositories/catalog_repository.dart';
import 'package:between_pages/features/catalog/application/repositories/catalog_repository.dart';
import 'package:between_pages/features/lists/application/repositories/reading_list_repository.dart';
import 'package:between_pages/core/constants/api_constants.dart';

class AddContentToListPage extends ConsumerStatefulWidget {
  final int listId;

  const AddContentToListPage({super.key, required this.listId});

  @override
  ConsumerState<AddContentToListPage> createState() =>
      _AddContentToListPageState();
}

class _AddContentToListPageState extends ConsumerState<AddContentToListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addItem(int contentId, String contentType) async {
    try {
      final repo = ref.read(readingListRepositoryProvider);
      await repo.addContentToList(widget.listId, contentId, contentType);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$contentType añadido a la lista')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir contenido'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Libros'),
            Tab(text: 'Mangas'),
            Tab(text: 'Fanfics'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBooksTab(),
                _buildMangasTab(),
                _buildFanficsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksTab() {
    return FutureBuilder<List<BookResponseDTO>>(
      future: ref.read(catalogRepositoryProvider).getAllBooks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final books = snapshot.data ?? [];
        final filtered = books
            .where((b) => b.title.toLowerCase().contains(
                _searchController.text.toLowerCase()))
            .toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No se encontraron libros'));
        }

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final book = filtered[index];
            return ListTile(
              leading: book.coverUrl != null
                  ? Image.network(
                      book.coverUrl!,
                      width: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.book),
                    )
                  : const Icon(Icons.book),
              title: Text(book.title),
              subtitle: Text(book.author),
              trailing: IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: () {
                  _addItem(book.idBook ?? 0, 'BOOK');
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMangasTab() {
    return FutureBuilder<List<MangaResponseDTO>>(
      future: ref.read(catalogRepositoryProvider).getAllManga(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final mangas = snapshot.data ?? [];
        final filtered = mangas
            .where((m) =>
                m.title.toLowerCase().contains(
                    _searchController.text.toLowerCase()))
            .toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No se encontraron mangas'));
        }

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final manga = filtered[index];
            return ListTile(
              leading: manga.coverUrl != null
                  ? Image.network(
                      manga.coverUrl!,
                      width: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image),
                    )
                  : const Icon(Icons.image),
              title: Text(manga.title),
              subtitle: Text(manga.author),
              trailing: IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: () {
                  _addItem(manga.idManga ?? 0, 'MANGA');
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFanficsTab() {
    return FutureBuilder<List<FanfictionResponseDTO>>(
      future: ref.read(catalogRepositoryProvider).getAllFanfics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final fanfics = snapshot.data ?? [];
        final filtered = fanfics
            .where((f) =>
                f.title.toLowerCase().contains(
                    _searchController.text.toLowerCase()))
            .toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No se encontraron fanfics'));
        }

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final fanfic = filtered[index];
            return ListTile(
              leading: fanfic.coverUrl != null
                  ? Image.network(
                      fanfic.coverUrl!,
                      width: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.article),
                    )
                  : const Icon(Icons.article),
              title: Text(fanfic.title),
              subtitle: Text(fanfic.author),
              trailing: IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: () {
                  _addItem(fanfic.idFanfic ?? 0, 'FANFIC');
                },
              ),
            );
          },
        );
      },
    );
  }
}
