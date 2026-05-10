import 'package:flutter/material.dart';
import 'package:between_pages/l10n/app_localizations.dart';

/// Etiqueta visual para indicar si un libro/manga es Físico, Digital o Prestado
class OwnershipBadge extends StatelessWidget {
  final String? ownership;

  const OwnershipBadge({super.key, required this.ownership});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        label = l10n.physical;
        break;
      case 'DIGITAL':
        icon = Icons.tablet_mac;
        color = Colors.blue.shade700;
        label = l10n.digital;
        break;
      case 'BORROWED':
        icon = Icons.people_alt;
        color = Colors.orange.shade700;
        label = l10n.borrowed;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
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