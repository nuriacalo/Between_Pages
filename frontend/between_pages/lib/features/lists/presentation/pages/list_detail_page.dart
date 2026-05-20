import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/media_item.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/catalog/presentation/widgets/media_list_item.dart';
import 'package:between_pages/features/lists/application/repositories/reading_list_repository.dart';
import 'package:between_pages/features/lists/domain/list_item_response_dto.dart';
import 'package:between_pages/features/lists/domain/list_response_dto.dart';
import 'package:between_pages/features/lists/domain/reading_list_detail_response_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
final listDetailProvider =
    FutureProvider.autoDispose.family<ReadingListDetailResponseDTO, int>(
  (ref, listId) {
    final repo = ref.watch(readingListRepositoryProvider);
    return repo.getListDetail(listId);
  },
);

class ListDetailPage extends ConsumerWidget {
  final ListResponseDTO list;

  const ListDetailPage({super.key, required this.list});

  MediaItem? _toMediaItem(ListItemResponseDTO item) {
    final type = item.itemType.toUpperCase();
    switch (type) {
      case 'BOOK':
        return item.book;
      case 'MANGA':
        return item.manga;
      case 'FANFIC':
        return item.fanfic;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(listDetailProvider(list.id));
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(listDetailProvider(list.id).future),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              pinned: true,
              title: Text(list.name),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Función de editar lista próximamente')),
                    );
                  },
                ),
              ],
            ),
            if (list.description != null && list.description!.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Text(
                    list.description!,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            detailAsync.when(
              data: (detail) {
                if (detail.items.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyList(),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  sliver: SliverList.separated(
                    itemCount: detail.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = detail.items[index];
                      final mediaItem = _toMediaItem(item);

                      if (mediaItem == null) {
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(child: Text('${item.position}')),
                            title: Text(item.itemType),
                            subtitle: const Text('Contenido no disponible'),
                          ),
                        );
                      }

                      return MediaListItem(
                        item: mediaItem,
                        onTap: () {
                          final type = item.itemType.toLowerCase();
                          int? mediaId;
                          if (mediaItem is BookResponseDTO) {
                            mediaId = mediaItem.idBook;
                          } else if (mediaItem is MangaResponseDTO) {
                            mediaId = mediaItem.idManga;
                          } else if (mediaItem is FanfictionResponseDTO) {
                            mediaId = mediaItem.idFanfic;
                          }

                          if (mediaId != null) {
                            context.push('/item/$type/$mediaId', extra: mediaItem);
                          }
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(child: Text('Error: ${error.toString()}')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/list/${list.id}/add-content');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.playlist_add_check_rounded,
          size: 64,
          color: colorScheme.onSurfaceVariant.withOpacity(0.4),
        ),
        const SizedBox(height: 16),
        Text(
          'Tu lista está vacía',
          style: textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Pulsa el botón + para añadir contenido\ndesde tu catálogo.',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
