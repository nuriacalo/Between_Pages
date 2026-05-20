import 'package:flutter/material.dart';


/// Selector de valoración con emojis estilo "rating de estrellas".
/// Funciona para lágrimas (💧) y spice (🔥), o cualquier otro emoji.
class EmojiRatingSelector extends StatelessWidget {
  final String emoji;
  final String label;
  final Color activeColor;
  final Color activeBg;
  final Color activeBorder;
  final int? value;        // 0..maxValue, null = sin selección
  final int maxValue;
  final ValueChanged<int?> onChanged;

  const EmojiRatingSelector({
    super.key,
    required this.emoji,
    required this.label,
    required this.activeColor,
    required this.activeBg,
    required this.activeBorder,
    this.value,
    this.maxValue = 5,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final current = value ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Etiqueta + contador ──────────────────────────────────────────
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: current > 0
                  ? Text(
                      '$current',
                      key: ValueKey(current),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: activeColor,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Fila de iconos ───────────────────────────────────────────────
        Row(
          children: [
            ...List.generate(maxValue, (index) {
              final position = index + 1;
              final isActive = position <= current;

              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () {
                    // Tap en el mismo valor activo = reset a 0
                    onChanged(position == current ? 0 : position);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: isActive
                          ? activeBg
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isActive
                            ? activeBorder
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: AnimatedScale(
                        scale: isActive ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 180),
                        child: Text(
                          emoji,
                          style: TextStyle(
                            fontSize: isActive ? 22 : 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}