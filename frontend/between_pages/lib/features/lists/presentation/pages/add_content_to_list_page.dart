import 'package:between_pages/features/catalog/application/repositories/catalog_repository.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/lists/application/repositories/reading_list_repository.dart';
import 'package:between_pages/features/profile/application/providers/user_provider.dart';
import 'package:between_pages/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Creamos proveedores para almacenar en caché los catálogos y no recargarlos al buscar
final _allBooksProvider = FutureProvider.autoDispose<List<BookResponseDTO>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  return ref.read(catalogRepositoryProvider).getAllBooks(user.idUser);
});

final _allMangaProvider = FutureProvider.autoDispose<List<MangaResponseDTO>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  return ref.read(catalogRepositoryProvider).getAllManga(user.idUser);
});

final _allFanficsProvider = FutureProvider.autoDispose<List<FanfictionResponseDTO>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  return ref.read(catalogRepositoryProvider).getAllFanfics(user.idUser);
});

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
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addContent),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.books),
            Tab(text: l10n.mangas),
            Tab(text: l10n.fanfics),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchTerm = value;
                });
              },
              decoration: InputDecoration(
                labelText: l10n.search,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBookList(),
                _buildMangaList(),
                _buildFanficList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookList() {
    final booksAsync = ref.watch(_allBooksProvider);
    return booksAsync.when(
      data: (data) {
        final books = data
            .where((book) =>
                book.title.toLowerCase().contains(_searchTerm.toLowerCase()))
            .toList();
        return ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return _buildItem(
              title: book.title,
              author: book.author,
              coverUrl: book.coverUrl,
              onTap: () => _addContent('BOOK', book.idBook!),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildMangaList() {
    final mangasAsync = ref.watch(_allMangaProvider);
    return mangasAsync.when(
      data: (data) {
        final mangas = data
            .where((manga) =>
                (manga.title ?? '').toLowerCase().contains(_searchTerm.toLowerCase()))
            .toList();
        return ListView.builder(
          itemCount: mangas.length,
          itemBuilder: (context, index) {
            final manga = mangas[index];
            return _buildItem(
              title: manga.title ?? 'Sin título',
              author: manga.author ?? 'Autor desconocido',
              coverUrl: manga.coverUrl,
              onTap: () => _addContent('MANGA', manga.idManga!),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildFanficList() {
    final fanficsAsync = ref.watch(_allFanficsProvider);
    return fanficsAsync.when(
      data: (data) {
        final fanfics = data
            .where((fanfic) =>
                (fanfic.title ?? '').toLowerCase().contains(_searchTerm.toLowerCase()))
            .toList();
        return ListView.builder(
          itemCount: fanfics.length,
          itemBuilder: (context, index) {
            final fanfic = fanfics[index];
            return _buildItem(
              title: fanfic.title ?? 'Sin título',
              author: fanfic.author ?? 'Autor desconocido',
              coverUrl: fanfic.coverUrl,
              onTap: () => _addContent('FANFIC', fanfic.idFanfic!),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildItem({
    required String title,
    required String author,
    String? coverUrl,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: coverUrl != null
          ? CachedNetworkImage(
              imageUrl: coverUrl,
              width: 40,
              height: 60,
              fit: BoxFit.cover,
            )
          : const Icon(Icons.book),
      title: Text(title),
      subtitle: Text(author),
      onTap: onTap,
    );
  }

  void _addContent(String contentType, int contentId) async {
    try {
      await ref
          .read(readingListRepositoryProvider)
          .addContentToList(widget.listId, contentId, contentType);
      if (mounted) {
        Navigator.of(context).pop(true); // Indicar que se añadió contenido
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Expanded(child: Text('No se pudo añadir a la lista. Es posible que ya exista.')),
              ],
            ),
            backgroundColor: Colors.orange.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }
}
