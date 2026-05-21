import 'package:flutter/material.dart';

/// A global widget that displays a beautiful badge indicating ownership status.
/// It has two styles: [solid] for detail pages and [overlay] for image covers.
class OwnershipBadge extends StatelessWidget {
  final String ownership;
  final bool isOverlay;

  const OwnershipBadge({
    super.key,
    required this.ownership,
    this.isOverlay = false,
  });

  IconData get _icon => switch (ownership.toUpperCase()) {
    'DIGITAL'  => Icons.phone_android_rounded,
    'PHYSICAL' => Icons.auto_stories_rounded,
    'BORROWED' => Icons.people_alt_rounded,
    _          => Icons.help_outline_rounded,
  };

  String get _label => switch (ownership.toUpperCase()) {
    'DIGITAL'  => 'Digital',
    'PHYSICAL' => 'Físico',
    'BORROWED' => 'Prestado',
    _          => ownership,
  };

  Color get _color => switch (ownership.toUpperCase()) {
    'DIGITAL'  => Colors.blueAccent,
    'PHYSICAL' => Colors.brown.shade400,
    'BORROWED' => Colors.orange.shade600,
    _          => Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    if (ownership.toUpperCase() == 'NONE' || ownership.isEmpty) {
      return const SizedBox.shrink();
    }

    if (isOverlay) {
      // Style used over book covers (semi-transparent black)
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha:0.65),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 10, color: _color.withValues(alpha: 0.7)),
            const SizedBox(width: 4),
            Text(
              _label,
              style: const TextStyle(
                fontSize: 9, 
                color: Colors.white, 
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      );
    }

    // Style used in detail pages (solid tinted backgrounds)
    return Tooltip(
      message: 'Propiedad: $_label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, color: _color, size: 14),
            const SizedBox(width: 4),
            Text(
              _label,
              style: TextStyle(
                color: _color.withValues(alpha: 0.9),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
