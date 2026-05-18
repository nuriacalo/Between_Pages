import 'package:flutter/material.dart';

class AngstLevelSelector extends StatelessWidget {
  final String? initialValue;
  final ValueChanged<String> onAngstLevelSelected;

  const AngstLevelSelector({
    super.key,
    required this.initialValue,
    required this.onAngstLevelSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> angstLevels = ['NONE', 'LOW', 'MEDIUM', 'HIGH', 'EXTREME'];
    final selectedAngst = initialValue ?? 'NONE';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nivel de Angst',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(angstLevels.length, (index) {
            final level = angstLevels[index];
            final isSelected = level == selectedAngst;
            return GestureDetector(
              onTap: () => onAngstLevelSelected(level),
              child: Column(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: isSelected
                        ? Colors.redAccent
                        : Colors.grey.withOpacity(0.5),
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    level,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.redAccent : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}