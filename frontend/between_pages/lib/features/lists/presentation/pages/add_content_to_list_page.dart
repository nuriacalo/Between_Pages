import 'package:between_pages/features/catalog/application/repositories/catalog_repository.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/lists/application/repositories/reading_list_repository.dart';
import 'package:between_pages/features/profile/application/providers/user_provider.dart';
import 'package:between_pages/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final userIdAsync = ref.watch(userProfileProvider);
    return userIdAsync.when(
      data: (user) {
        return FutureBuilder<List<BookResponseDTO>>(
          future: ref.read(catalogRepositoryProvider).getAllBooks(user.idUser),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final books = snapshot.data
                    ?.where((book) => book.title
                        .toLowerCase()
                        .contains(_searchTerm.toLowerCase()))
                    .toList() ??
                [];
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
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildMangaList() {
    final userIdAsync = ref.watch(userProfileProvider);
    return userIdAsync.when(
      data: (user) {
        return FutureBuilder<List<MangaResponseDTO>>(
          future: ref.read(catalogRepositoryProvider).getAllManga(user.idUser),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final mangas = snapshot.data
                    ?.where((manga) => (manga.title ?? '')
                        .toLowerCase()
                        .contains(_searchTerm.toLowerCase()))
                    .toList() ??
                [];
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
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildFanficList() {
    final userIdAsync = ref.watch(userProfileProvider);
    return userIdAsync.when(
      data: (user) {
        return FutureBuilder<List<FanfictionResponseDTO>>(
          future: ref.read(catalogRepositoryProvider).getAllFanfics(user.idUser),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final fanfics = snapshot.data
                    ?.where((fanfic) => (fanfic.title ?? '')
                        .toLowerCase()
                        .contains(_searchTerm.toLowerCase()))
                    .toList() ??
                [];
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
          SnackBar(content: Text('Error al añadir: $e')),
        );
      }
    }
  }
}
