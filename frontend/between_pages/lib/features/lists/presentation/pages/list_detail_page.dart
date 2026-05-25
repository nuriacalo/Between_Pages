import 'package:between_pages/core/theme/app_colors.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/catalog/presentation/widgets/media_list_item.dart';
import 'package:between_pages/features/lists/application/repositories/reading_list_repository.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(listDetailProvider(list.id));
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: RefreshIndicator(
        color: AppColors.accent(context),
        onRefresh: () => ref.refresh(listDetailProvider(list.id).future),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── SliverAppBar expandible ────────────────────────────────────
            SliverAppBar(
              expandedHeight: 155,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.surface(context),
              surfaceTintColor: Colors.transparent,
              leading: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  color: Colors.transparent,
                  child: Icon(Icons.arrow_back_rounded,
                      color: AppColors.textPrimary(context), size: 20),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.card(context).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.edit_outlined,
                        size: 18,
                        color: AppColors.textSecondary(context)),
                    onPressed: () =>
                        ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Editar lista — próximamente')),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Container(
                  color: AppColors.surface(context),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.of(context).padding.top + 56,
                    20,
                    16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.emphasis(context)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'COLECCIÓN',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.emphasis(context),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        list.name,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (list.description != null &&
                          list.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          list.description!,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // ── Divisor + contador ─────────────────────────────────────────
            detailAsync.maybeWhen(
              data: (detail) => SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: AppColors.border(context), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.accent(context),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${detail.items.length} '
                        '${detail.items.length == 1 ? 'obra' : 'obras'}',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              orElse: () =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // ── Items ──────────────────────────────────────────────────────
            detailAsync.when(
              data: (detail) {
                if (detail.items.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyDetail(),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  sliver: SliverList.separated(
                    itemCount: detail.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = detail.items[index];
                      final mediaItem = item.mediaItem;

                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.card(context),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColors.border(context)),
                            ),
                            child: mediaItem == null
                                ? ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.accent(context)
                                          .withValues(alpha: 0.15),
                                      child: Text(
                                        '${item.position}',
                                        style: TextStyle(
                                            color:
                                                AppColors.accent(context)),
                                      ),
                                    ),
                                    title: Text(item.itemType),
                                    subtitle:
                                        const Text('Contenido no disponible'),
                                  )
                                : MediaListItem(
                                    item: mediaItem,
                                    onTap: () {
                                      final type =
                                          item.itemType.toLowerCase();
                                      int? mediaId;
                                      if (mediaItem is BookResponseDTO) {
                                        mediaId = mediaItem.idBook;
                                      } else if (mediaItem
                                          is MangaResponseDTO) {
                                        mediaId = mediaItem.idManga;
                                      } else if (mediaItem
                                          is FanfictionResponseDTO) {
                                        mediaId = mediaItem.idFanfic;
                                      }
                                      if (mediaId != null) {
                                        context.push(
                                            '/item/$type/$mediaId',
                                            extra: mediaItem);
                                      }
                                    },
                                  ),
                          ),
                          // Badge de posición
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: AppColors.emphasis(context)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${index + 1}',
                                style: textTheme.labelSmall?.copyWith(
                                  color: AppColors.emphasis(context),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
              loading: () => SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent(context),
                  ),
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/list/${list.id}/add-content'),
        backgroundColor: AppColors.accent(context),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EmptyDetail
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyDetail extends StatelessWidget {
  const _EmptyDetail();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accent(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.playlist_add_rounded,
                size: 32,
                color: AppColors.accent(context).withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Lista vacía',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Pulsa el botón + para añadir obras desde tu catálogo.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary(context),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}