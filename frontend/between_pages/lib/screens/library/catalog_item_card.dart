import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CatalogItemCard extends StatelessWidget {
  final String title;
  final String author;
  final String? coverUrl;
  final IconData fallbackIcon;
  final bool isFanfic;
  final VoidCallback onTap;

  const CatalogItemCard({
    super.key,
    required this.title,
    required this.author,
    this.coverUrl,
    required this.fallbackIcon,
    this.isFanfic = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isFanfic
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildImage(colorScheme),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          Text(
            author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(ColorScheme colorScheme) {
    if (coverUrl != null && coverUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: coverUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (context, url, error) => _buildFallback(colorScheme),
      );
    }
    return _buildFallback(colorScheme);
  }

  Widget _buildFallback(ColorScheme colorScheme) {
    return Center(
      child: Icon(
        fallbackIcon,
        size: 40,
        color: isFanfic ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
      ),
    );
  }
}