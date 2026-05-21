import 'package:between_pages/core/theme/app_colors.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/catalog/domain/media_item.dart';
import 'package:between_pages/features/catalog/presentation/widgets/ownership_badge.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MediaListItem extends StatelessWidget {
  final MediaItem item;
  final VoidCallback? onTap;

  const MediaListItem({super.key, required this.item, this.onTap});

  // ── Type helpers ─────────────────────────────────────────────────────────

  Color _accentColor(BuildContext context) => switch (item.itemType) {
        MediaType.book   => AppColors.colorLibro,
        MediaType.manga  => AppColors.colorManga,
        MediaType.fanfic => AppColors.colorFanfic,
      };

  IconData get _fallbackIcon => switch (item.itemType) {
        MediaType.book   => Icons.book_rounded,
        MediaType.manga  => Icons.menu_book_rounded,
        MediaType.fanfic => Icons.favorite_rounded,
      };

  String get _typeLabel => switch (item.itemType) {
        MediaType.book   => 'Libro',
        MediaType.manga  => 'Manga',
        MediaType.fanfic => 'Fanfic',
      };

  List<String> get _genres => switch (item.itemType) {
        MediaType.book   => (item as BookResponseDTO).genres,
        MediaType.manga  => (item as MangaResponseDTO).genres,
        MediaType.fanfic => (item as FanfictionResponseDTO).genres,
      };

  String? get _ownership => switch (item.itemType) {
        MediaType.book   => null, // books don't carry ownership at catalog level
        MediaType.manga  => null,
        MediaType.fanfic => null,
      };

  // ── Type-specific extra info row ─────────────────────────────────────────

  Widget? _extraInfo(BuildContext context, Color accent) {
    switch (item.itemType) {
      case MediaType.manga:
        final m = item as MangaResponseDTO;
        final parts = <String>[];
        if (m.totalVolumes != null) parts.add('${m.totalVolumes} vol.');
        if (m.totalChapters != null) parts.add('${m.totalChapters} cap.');
        if (m.demographic.isNotEmpty) parts.add(m.demographic);
        if (parts.isEmpty) return null;
        return _ExtraRow(
          icon: Icons.format_list_numbered_rounded,
          text: parts.join(' · '),
          color: accent,
        );

      case MediaType.fanfic:
        final f = item as FanfictionResponseDTO;
        final parts = <String>[];
        if (f.totalChapters != null) parts.add('${f.totalChapters} cap.');
        if (f.mainShip != null && f.mainShip!.isNotEmpty) parts.add(f.mainShip!);
        if (parts.isEmpty) return null;
        return _ExtraRow(
          icon: Icons.favorite_border_rounded,
          text: parts.join(' · '),
          color: accent,
        );

      case MediaType.book:
        final b = item as BookResponseDTO;
        if (b.pageCount == null) return null;
        return _ExtraRow(
          icon: Icons.auto_stories_rounded,
          text: '${b.pageCount} páginas',
          color: accent,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final accent      = _accentColor(context);
    final genres      = _genres.take(3).toList();
    final extra       = _extraInfo(context, accent);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color:        isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left accent bar ─────────────────────────────────────
              Container(width: 4, color: accent),

              // ── Cover ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(10),
                child: _Cover(
                  coverUrl:    item.coverImageUrl,
                  accent:      accent,
                  fallback:    _fallbackIcon,
                  ownership:   _ownership,
                ),
              ),

              // ── Body ────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:  MainAxisAlignment.center,
                    children: [
                      // Type eyebrow
                      Text(
                        _typeLabel.toUpperCase(),
                        style: TextStyle(
                          fontSize:      9,
                          fontWeight:    FontWeight.bold,
                          color:         accent,
                          letterSpacing: 0.7,
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Title
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow:  TextOverflow.ellipsis,
                        style:     textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color:      AppColors.textPrimary(context),
                          height:     1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Author
                      Text(
                        item.author,
                        maxLines: 1,
                        overflow:  TextOverflow.ellipsis,
                        style:     textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      // Genre chips
                      if (genres.isNotEmpty) ...[
                        const SizedBox(height: 7),
                        Wrap(
                          spacing:    5,
                          runSpacing: 3,
                          children: genres
                              .map((g) => _GenreChip(label: g, color: accent))
                              .toList(),
                        ),
                      ],
                      // Type-specific extra row
                      if (extra != null) ...[
                        const SizedBox(height: 6),
                        extra,
                      ],
                    ],
                  ),
                ),
              ),

              // ── Chevron ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size:  18,
                  color: colorScheme.outlineVariant,
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Cover extends StatelessWidget {
  final String?  coverUrl;
  final Color    accent;
  final IconData fallback;
  final String?  ownership;

  const _Cover({
    required this.coverUrl,
    required this.accent,
    required this.fallback,
    this.ownership,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  58,
      height: 84,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox.expand(
              child: coverUrl != null && coverUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl:    coverUrl!,
                      fit:         BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: accent.withValues(alpha: 0.12),
                      ),
                      errorWidget: (_, _, _) => _Fallback(
                        accent: accent, icon: fallback,
                      ),
                    )
                  : _Fallback(accent: accent, icon: fallback),
            ),
          ),
          if (ownership != null &&
              ownership!.isNotEmpty &&
              ownership!.toUpperCase() != 'NONE')
            Positioned(
              top:  3,
              left: 3,
              child: OwnershipBadge(ownership: ownership!, isOverlay: true),
            ),
        ],
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  final Color    accent;
  final IconData icon;
  const _Fallback({required this.accent, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        color: accent.withValues(alpha: 0.1),
        child: Center(
          child: Icon(icon, size: 24, color: accent.withValues(alpha: 0.45)),
        ),
      );
}

class _GenreChip extends StatelessWidget {
  final String label;
  final Color  color;
  const _GenreChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color:        color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize:   9,
            color:      color,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _ExtraRow extends StatelessWidget {
  final IconData icon;
  final String   text;
  final Color    color;
  const _ExtraRow({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 11, color: color.withValues(alpha: 0.7)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize:   10,
                color:      color.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
}