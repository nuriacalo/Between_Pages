import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:between_pages/screens/detail/ownership_badge.dart';

/// Modelo de datos normalizado para cualquier item de journal (libro, manga, fanfic).
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

/// Card genérica para cualquier tipo de journal item.
/// Unifica _BookCard y _MangaCard eliminando ~100 líneas de duplicación.
class JournalItemCard extends StatelessWidget {
  final JournalItemData item;
  final IconData fallbackIcon;

  const JournalItemCard({
    super.key,
    required this.item,
    this.fallbackIcon = Icons.book,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => context.push(item.route, extra: item.extra),
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 110,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
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
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildCover(context),
                      if (item.ownership != null)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: OwnershipBadge(ownership: item.ownership),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (item.subtitle != null)
                Text(
                  item.subtitle!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (item.coverUrl != null && item.coverUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: item.coverUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (context, url) => Container(
          color: colorScheme.surfaceContainerHighest,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => _buildFallback(context),
      );
    }
    return _buildFallback(context);
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(fallbackIcon, size: 32),
    );
  }
}

