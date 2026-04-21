import 'package:flutter/material.dart';

/// Etiqueta visual para indicar si un libro/manga es Físico, Digital o Prestado
class OwnershipBadge extends StatelessWidget {
  final String? ownership;

  const OwnershipBadge({super.key, required this.ownership});

  @override
  Widget build(BuildContext context) {
    // Si no hay propiedad o es NONE, no mostramos nada
    if (ownership == null || ownership == 'NONE') {
      return const SizedBox.shrink();
    }

    IconData icon;
    Color color;
    String label;

    switch (ownership) {
      case 'PHYSICAL':
        icon = Icons.book;
        color = Colors.brown.shade700;
        label = 'Físico';
        break;
      case 'DIGITAL':
        icon = Icons.tablet_mac;
        color = Colors.blue.shade700;
        label = 'Digital';
        break;
      case 'BORROWED':
        icon = Icons.people_alt;
        color = Colors.orange.shade700;
        label = 'Prestado';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}