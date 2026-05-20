import 'package:between_pages/features/home/presentation/pages/home_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:between_pages/features/catalog/presentation/widgets/ownership_badge.dart';

/// Normalized data model for rendering any type of journal item (Book, Manga, Fanfic)
/// in a consistent card format.
class JournalItemData {
  final int id;
  final String title;
  final String? coverUrl;
  final String? subtitle;
  final String? ownership;
  final String route;
  final dynamic extra;

  const JournalItemData({
    required this.id,
    required this.title,
    this.coverUrl,
    this.subtitle,
    this.ownership,
    required this.route,
    required this.extra,
  });
}

/// A highly reusable, visually appealing card widget for displaying media items.
class JournalItemCard extends ConsumerWidget { // Converted to ConsumerWidget
  final JournalItemData item;
  final IconData fallbackIcon;

  const JournalItemCard({
    super.key,
    required this.item,
    this.fallbackIcon = Icons.book,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Added WidgetRef
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          // Update the last read item provider
          ref.read(lastReadItemProvider.notifier).state = item.extra;
          
          // Original navigation logic
          context.push(item.route, extra: item.extra);
        },
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 110,
          child: Container(
            height: 150,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildCover(context),
                Positioned(
                  left: 0, right: 0, bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xCC000000), Colors.transparent],
                        stops: [0.0, 1.0],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.25,
                            shadows: [Shadow(blurRadius: 3, color: Colors.black54)],
                          ),
                        ),
                        if (item.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle!,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (item.ownership != null)
                  Positioned(
                    top: 6, left: 6,
                    child: OwnershipBadge(ownership: item.ownership!, isOverlay: true),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    if (item.coverUrl != null && item.coverUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: item.coverUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (_, _) => _buildFallback(context),
        errorWidget: (_, _, _) => _buildFallback(context),
      );
    }
    return _buildFallback(context);
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(child: Icon(fallbackIcon, size: 32, color: Colors.grey)),
    );
  }
}