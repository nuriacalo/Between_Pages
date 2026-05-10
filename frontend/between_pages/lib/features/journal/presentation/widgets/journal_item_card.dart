import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Portada ─────────────────────────────────────────────
                _buildCover(context),

                // ── Gradiente + título dentro de la portada ──────────────
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

                // ── Badge de propiedad ────────────────────────────────────
                if (item.ownership != null)
                  Positioned(
                    top: 6, left: 6,
                    child: _OwnershipBadge(ownership: item.ownership!),
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
        placeholder: (_, __) => _buildFallback(context),
        errorWidget: (_, __, ___) => _buildFallback(context),
      );
    }
    return _buildFallback(context);
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(child: Icon(fallbackIcon, size: 32, color: Colors.white38)),
    );
  }
}

// Badge semitransparente sobre la portada
class _OwnershipBadge extends StatelessWidget {
  final String ownership;
  const _OwnershipBadge({required this.ownership});

  IconData get _icon => switch (ownership.toUpperCase()) {
    'DIGITAL'  => Icons.phone_android_rounded,
    'PHYSICAL' => Icons.storefront_rounded,
    'BORROWED' => Icons.person_pin_rounded,
    _          => Icons.help_outline_rounded,
  };

  String get _label => switch (ownership.toUpperCase()) {
    'DIGITAL'  => 'Digital',
    'PHYSICAL' => 'Físico',
    'BORROWED' => 'Prestado',
    _          => ownership,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 10, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            _label,
            style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}