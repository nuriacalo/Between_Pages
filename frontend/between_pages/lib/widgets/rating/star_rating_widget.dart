import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Valoración por estrellas (0.5 - 5.0) con soporte de medias estrellas.
/// Convierte internamente a escala 1-10 para el backend:
///   backendToStars(n)  = n / 2.0
///   starsToBackend(s)  = (s * 2).round()
class StarRatingWidget extends StatefulWidget {
  final double stars; // 0.0 – 5.0
  final ValueChanged<double>? onChanged; // null → solo visualización
  final double starSize;
  final bool showLabel;

  const StarRatingWidget({
    super.key,
    required this.stars,
    this.onChanged,
    this.starSize = 30,
    this.showLabel = true,
  });

  /// Convierte valoración del backend (1-10) a estrellas (0.0-5.0)
  static double backendToStars(int? rating) => (rating ?? 0) / 2.0;

  /// Convierte estrellas (0.5-5.0) a valoración del backend (1-10)
  static int starsToBackend(double stars) => (stars * 2).round().clamp(0, 10);

  static String starsLabel(double stars) {
    if (stars == 0) return 'Sin valorar';
    if (stars <= 1) return 'No me gustó';
    if (stars <= 2) return 'Regular';
    if (stars <= 3) return 'Estaba bien';
    if (stars <= 4) return 'Me gustó';
    if (stars < 5) return '¡Muy bueno!';
    return '¡Obra maestra!';
  }

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  late double _current;

  @override
  void initState() {
    super.initState();
    _current = widget.stars;
  }

  @override
  void didUpdateWidget(StarRatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stars != widget.stars) _current = widget.stars;
  }

  void _handleTap(int index, TapDownDetails details, BoxConstraints constraints) {
    if (widget.onChanged == null) return;
    final starWidth = constraints.maxWidth / 5;
    final starIndex = (details.localPosition.dx / starWidth).floor().clamp(0, 4);
    final withinStar = details.localPosition.dx - starIndex * starWidth;
    final newRating = withinStar < starWidth / 2
        ? starIndex + 0.5
        : starIndex + 1.0;
    final clamped = newRating.clamp(0.5, 5.0);
    HapticFeedback.selectionClick();
    setState(() => _current = clamped);
    widget.onChanged!(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emptyColor = isDark
        ? const Color(0xFF5C4448)
        : const Color(0xFFE8D5C8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onTapDown: widget.onChanged != null
                  ? (d) => _handleTap(0, d, constraints)
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  final IconData icon;
                  if (_current >= i + 1) {
                    icon = Icons.star_rounded;
                  } else if (_current >= i + 0.5) {
                    icon = Icons.star_half_rounded;
                  } else {
                    icon = Icons.star_outline_rounded;
                  }
                  final isFilled = _current >= i + 0.5;
                  return AnimatedScale(
                    scale: isFilled ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      icon,
                      size: widget.starSize,
                      color: isFilled
                          ? const Color(0xFFE8C47A)
                          : emptyColor,
                    ),
                  );
                }),
              ),
            );
          },
        ),
        if (widget.showLabel && widget.onChanged != null) ...[
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _current > 0
                  ? '${StarRatingWidget.starsLabel(_current)} · $_current★'
                  : 'Toca para valorar',
              key: ValueKey(_current),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _current > 0
                        ? const Color(0xFFE8C47A)
                        : Theme.of(context).colorScheme.outline,
                    fontStyle: _current == 0 ? FontStyle.italic : null,
                  ),
            ),
          ),
        ],
      ],
    );
  }
}
