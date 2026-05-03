import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Valoración de impacto emocional con gotas de llanto (0 - 5)
class DropRatingWidget extends StatefulWidget {
  final int drops; // 0 – 5
  final ValueChanged<int>? onChanged;
  final double iconSize;
  final bool showLabel;

  const DropRatingWidget({
    super.key,
    required this.drops,
    this.onChanged,
    this.iconSize = 28,
    this.showLabel = true,
  });

  static String dropLabel(int drops) {
    switch (drops) {
      case 0: return 'Sin lágrimas';
      case 1: return 'Un poco emotivo';
      case 2: return 'Se me hizo un nudo';
      case 3: return 'Lloré';
      case 4: return 'Lloré mucho';
      case 5: return 'Destrozado/a';
      default: return '';
    }
  }

  @override
  State<DropRatingWidget> createState() => _DropRatingWidgetState();
}

class _DropRatingWidgetState extends State<DropRatingWidget> {
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.drops;
  }

  @override
  void didUpdateWidget(DropRatingWidget old) {
    super.didUpdateWidget(old);
    if (old.drops != widget.drops) _current = widget.drops;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark
        ? const Color(0xFF7BAED4)
        : const Color(0xFF4A90C4);
    final inactiveColor = isDark
        ? const Color(0xFF5C4448)
        : const Color(0xFFE8D5C8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            final filled = i < _current;
            return GestureDetector(
              onTap: widget.onChanged != null
                  ? () {
                      HapticFeedback.selectionClick();
                      final newVal = i + 1 == _current ? 0 : i + 1;
                      setState(() => _current = newVal);
                      widget.onChanged!(newVal);
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: AnimatedScale(
                  scale: filled ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    filled ? Icons.water_drop_rounded : Icons.water_drop_outlined,
                    size: widget.iconSize,
                    color: filled ? activeColor : inactiveColor,
                  ),
                ),
              ),
            );
          }),
        ),
        if (widget.showLabel) ...[
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              DropRatingWidget.dropLabel(_current),
              key: ValueKey(_current),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _current > 0
                        ? const Color(0xFF7BAED4)
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

/// Valoración de nivel romántico/picante con llamas (0 - 5)
class FlameRatingWidget extends StatefulWidget {
  final int flames; // 0 – 5
  final ValueChanged<int>? onChanged;
  final double iconSize;
  final bool showLabel;

  const FlameRatingWidget({
    super.key,
    required this.flames,
    this.onChanged,
    this.iconSize = 28,
    this.showLabel = true,
  });

  static String flameLabel(int flames) {
    switch (flames) {
      case 0: return 'Sin romance';
      case 1: return 'Un toque romántico';
      case 2: return 'Romanticismo moderado';
      case 3: return 'Bastante picante';
      case 4: return 'Muy intenso';
      case 5: return '🔥 Quema las páginas';
      default: return '';
    }
  }

  @override
  State<FlameRatingWidget> createState() => _FlameRatingWidgetState();
}

class _FlameRatingWidgetState extends State<FlameRatingWidget> {
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.flames;
  }

  @override
  void didUpdateWidget(FlameRatingWidget old) {
    super.didUpdateWidget(old);
    if (old.flames != widget.flames) _current = widget.flames;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark
        ? const Color(0xFFE8A87C)
        : const Color(0xFFD4703A);
    final inactiveColor = isDark
        ? const Color(0xFF5C4448)
        : const Color(0xFFE8D5C8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            final filled = i < _current;
            return GestureDetector(
              onTap: widget.onChanged != null
                  ? () {
                      HapticFeedback.selectionClick();
                      final newVal = i + 1 == _current ? 0 : i + 1;
                      setState(() => _current = newVal);
                      widget.onChanged!(newVal);
                    }
                  : null,
              child: AnimatedScale(
                scale: filled ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    filled ? Icons.local_fire_department_rounded : Icons.local_fire_department_outlined,
                    size: widget.iconSize,
                    color: filled ? activeColor : inactiveColor,
                  ),
                ),
              ),
            );
          }),
        ),
        if (widget.showLabel) ...[
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              FlameRatingWidget.flameLabel(_current),
              key: ValueKey(_current),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _current > 0
                        ? const Color(0xFFE8A87C)
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
