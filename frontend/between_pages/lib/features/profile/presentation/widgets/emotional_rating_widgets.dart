import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          children: List.generate(5, (index) => IconButton(
            icon: Icon(
              Icons.water_drop,
              color: index < tearDrops ? Colors.blue : colorScheme.onSurfaceVariant,
            ),
            onPressed: () => onTearDropsChanged(index + 1),
          )),
        ),
        Row(
          children: List.generate(5, (index) => IconButton(
            icon: Icon(
              Icons.local_fire_department,
              color: index < spiceFlames ? Colors.red : colorScheme.onSurfaceVariant,
            ),
            onPressed: () => onSpiceFlamesChanged(index + 1),
          )),
        ),
      ],
    );
  }
}

