import 'package:flutter/material.dart';
import 'package:between_pages/features/catalog/domain/media_item.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';

class MediaListItem extends StatelessWidget {
  final MediaItem item;

  const MediaListItem({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Cover Image
            Container(
              width: 80,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: item.coverImageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(item.coverImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.grey[300],
              ),
              child: item.coverImageUrl == null
                  ? const Icon(Icons.book, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 16),
            // Title, Author, and Adaptive Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.headline6,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.author,
                    style: Theme.of(context).textTheme.bodyText2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Adaptive Details Section
                  _buildTypeSpecificDetails(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSpecificDetails(BuildContext context) {
    switch (item.itemType) {
      case MediaType.manga:
        final manga = item as MangaResponseDTO;
        return Row(
          children: [
            Chip(
              label: Text('Vols: ${manga.volumes ?? 'N/A'}'),
              backgroundColor: Theme.of(context).extension<CustomColors>()!.colorManga?.withOpacity(0.2),
            ),
          ],
        );
      case MediaType.fanfic:
        final fanfic = item as FanfictionResponseDTO;
        return Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: [
            if (fanfic.mainShip != null) Chip(label: Text(fanfic.mainShip!)),
            Chip(label: Text('Angst: ${fanfic.angstLevel ?? 0}/5')),
          ],
        );
      case MediaType.book:
      default:
        // For books, we might not show anything extra, or perhaps the page count.
        return const SizedBox.shrink();
    }
  }
}
