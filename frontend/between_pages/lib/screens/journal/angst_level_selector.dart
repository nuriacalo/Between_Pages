import 'package:flutter/material.dart';

class AngstLevelSelector extends StatelessWidget {
  final String? initialLevel;
  final ValueChanged<String?> onChanged;
  final String? label;

  const AngstLevelSelector({
    super.key,
    this.initialLevel,
    required this.onChanged,
    this.label = 'Nivel de angst',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levels = ['NONE', 'LOW', 'MEDIUM', 'HIGH', 'EXTREME'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: levels.map((level) {
              final isSelected = initialLevel == level;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  label: Text(level),
                  selected: isSelected,
                  onSelected: (_) => onChanged(level),
                  selectedColor: colorScheme.primaryContainer,
                  checkmarkColor: colorScheme.onPrimaryContainer,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

