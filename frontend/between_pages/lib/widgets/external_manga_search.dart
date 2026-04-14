import 'package:between_pages/models/catalog/manga_response_dto.dart';
import 'package:between_pages/providers/external/external_manga_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget de ejemplo para buscar manga en fuentes externas (MyAnimeList)
/// El backend se encarga de consultar Jikan API.
class ExternalMangaSearch extends ConsumerStatefulWidget {
  const ExternalMangaSearch({super.key});

  @override
  ConsumerState<ExternalMangaSearch> createState() =>
      _ExternalMangaSearchState();
}

class _ExternalMangaSearchState extends ConsumerState<ExternalMangaSearch> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      // El backend consulta a MyAnimeList vía Jikan
      ref.read(externalMangaSearchProvider.notifier).searchManga(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observa los providers de búsqueda externa
    final results = ref.watch(externalMangaSearchResultsProvider);
    final isLoading = ref.watch(externalMangaSearchLoadingProvider);
    final error = ref.watch(externalMangaSearchErrorProvider);

    return Column(
      children: [
        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar manga en MyAnimeList...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(externalMangaSearchProvider.notifier)
                                  .clearResults();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: isLoading ? null : _performSearch,
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: const Text('Buscar'),
              ),
            ],
          ),
        ),

        // Mensaje de error
        if (error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Info de fuente
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(Icons.public, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                'Fuente: MyAnimeList',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const Spacer(),
              Text(
                'Vía backend → Jikan API',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Lista de resultados
        Expanded(
          child: results.isEmpty && !isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu_book,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Busca manga por título',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final manga = results[index];
                    return _MangaResultCard(manga: manga);
                  },
                ),
        ),
      ],
    );
  }
}

/// Card individual para mostrar un resultado de manga
class _MangaResultCard extends StatelessWidget {
  final MangaResponseDTO manga;

  const _MangaResultCard({required this.manga});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // Aquí puedes navegar al detalle del manga
          // o añadirlo al journal
          _showAddOptions(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Portada
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: manga.coverUrl != null
                    ? Image.network(
                        manga.coverUrl!,
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              const SizedBox(width: 16),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manga.title ?? 'Sin título',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      manga.mangaka ?? 'Autor desconocido',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (manga.genre != null && manga.genre!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        manga.genre!,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (manga.totalChapters != null)
                          _buildChip('${manga.totalChapters} cap.'),
                        if (manga.publicationStatus != null) ...[
                          const SizedBox(width: 8),
                          _buildChip(manga.publicationStatus!, isStatus: true),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 120,
      color: Colors.grey.shade300,
      child: const Icon(Icons.book, color: Colors.grey),
    );
  }

  Widget _buildChip(String label, {bool isStatus = false}) {
    Color backgroundColor = Colors.grey.shade200;
    if (isStatus) {
      switch (label.toUpperCase()) {
        case 'ONGOING':
        case 'PUBLISHING':
          backgroundColor = Colors.green.shade100;
          break;
        case 'COMPLETED':
        case 'FINISHED':
          backgroundColor = Colors.blue.shade100;
          break;
        case 'PAUSED':
        case 'HIATUS':
          backgroundColor = Colors.orange.shade100;
          break;
        case 'CANCELLED':
          backgroundColor = Colors.red.shade100;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Añadir a mi biblioteca'),
              subtitle: Text(manga.title ?? ''),
              onTap: () {
                // Implementa la lógica para añadir al backend
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Manga añadido a la biblioteca'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_add),
              title: const Text('Añadir a lista de lectura'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('Ver en MyAnimeList'),
              onTap: () {
                // Abre el enlace a MyAnimeList
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
