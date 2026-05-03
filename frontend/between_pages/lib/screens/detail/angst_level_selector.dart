import 'package:flutter/material.dart';

/// Selector visual (Termómetro) para el nivel de Angst de un Fanfic
class AngstLevelSelector extends StatelessWidget {
  final String? currentLevel;
  final ValueChanged<String> onChanged;

  const AngstLevelSelector({
    super.key,
    required this.currentLevel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final levels = ['NONE', 'LOW', 'MEDIUM', 'HIGH', 'EXTREME'];
    final labels = ['Ninguno', 'Bajo', 'Medio', 'Alto', 'Extremo'];
    
    // Los colores van subiendo de intensidad (Verde -> Rojo)
    final colors = [
      Colors.green,
      Colors.blue,
      Colors.amber,
      Colors.orange,
      Colors.red,
    ];

    int currentIndex = levels.indexOf(currentLevel ?? 'NONE');
    if (currentIndex == -1) currentIndex = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nivel de Angst (Sufrimiento): ${labels[currentIndex]}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors[currentIndex],
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: currentIndex.toDouble(),
          min: 0,
          max: 4,
          divisions: 4,
          activeColor: colors[currentIndex],
          inactiveColor: colors[currentIndex].withValues(alpha: 0.3),
          onChanged: (val) {
            onChanged(levels[val.toInt()]);
          },
        ),
      ],
    );
  }
}