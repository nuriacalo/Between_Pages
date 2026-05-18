import 'package:flutter/material.dart';

/// A beautiful and interactive widget for selecting tear drops (sadness) 
/// and spice flames (romance/spice).
class EmotionalRatingWidgets extends StatelessWidget {
  final int tearDrops;
  final int spiceFlames;
  final Function(int) onTearDropsChanged;
  final Function(int) onSpiceFlamesChanged;

  const EmotionalRatingWidgets({
    super.key,
    required this.tearDrops,
    required this.spiceFlames,
    required this.onTearDropsChanged,
    required this.onSpiceFlamesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRatingRow(
          context: context,
          label: 'Nivel de lágrimas',
          value: tearDrops,
          max: 5,
          activeIcon: Icons.water_drop_rounded,
          inactiveIcon: Icons.water_drop_outlined,
          activeColor: Colors.blueAccent,
          onChanged: onTearDropsChanged,
        ),
        const SizedBox(height: 16),
        _buildRatingRow(
          context: context,
          label: 'Nivel de picante',
          value: spiceFlames,
          max: 5,
          activeIcon: Icons.local_fire_department_rounded,
          inactiveIcon: Icons.local_fire_department_outlined,
          activeColor: Colors.deepOrangeAccent,
          onChanged: onSpiceFlamesChanged,
        ),
      ],
    );
  }

  Widget _buildRatingRow({
    required BuildContext context,
    required String label,
    required int value,
    required int max,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required Color activeColor,
    required Function(int) onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(max, (index) {
              final isSelected = index < value;
              return GestureDetector(
                onTap: () {
                  // If tapping the currently selected maximum, reset to 0
                  if (value == index + 1) {
                    onChanged(0);
                  } else {
                    onChanged(index + 1);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: AnimatedScale(
                    scale: isSelected ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isSelected ? activeIcon : inactiveIcon,
                        size: 32,
                        color: isSelected 
                            ? activeColor 
                            : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        shadows: isSelected 
                            ? [Shadow(color: activeColor.withValues(alpha: 0.4), blurRadius: 8)] 
                            : null,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
