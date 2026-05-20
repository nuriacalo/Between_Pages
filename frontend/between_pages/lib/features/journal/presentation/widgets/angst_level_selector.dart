import 'package:between_pages/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class AngstLevelSelector extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String> onAngstLevelSelected;

  const AngstLevelSelector({
    super.key,
    required this.initialValue,
    required this.onAngstLevelSelected,
  });

  @override
  State<AngstLevelSelector> createState() => _AngstLevelSelectorState();
}

class _AngstLevelSelectorState extends State<AngstLevelSelector> {
  late String _selectedAngst;
  final List<String> _angstLevels = ['NONE', 'LOW', 'MEDIUM', 'HIGH', 'EXTREME'];

  @override
  void initState() {
    super.initState();
    _selectedAngst = widget.initialValue ?? 'NONE';
  }

  String _getTranslatedLevel(BuildContext context, String level) {
    final l10n = AppLocalizations.of(context)!;
    switch (level) {
      case 'NONE':
        return l10n.angstLevelNone;
      case 'LOW':
        return l10n.angstLevelLow;
      case 'MEDIUM':
        return l10n.angstLevelMedium;
      case 'HIGH':
        return l10n.angstLevelHigh;
      case 'EXTREME':
        return l10n.angstLevelExtreme;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = const Color(0xFF8B6BAE); // Mismo color acento unificado del Fanfic
    final activeBg = activeColor.withOpacity(0.15);
    final inactiveColor = Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.angstLevelTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_angstLevels.length, (index) {
            final level = _angstLevels[index];
            final isSelected = _angstLevels.indexOf(_selectedAngst) >= index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAngst = level;
                });
                widget.onAngstLevelSelected(level);
              },
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? activeBg
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? activeColor : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: AnimatedScale(
                        scale: isSelected ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 180),
                        child: Icon(
                          Icons.heart_broken,
                          color: isSelected ? activeColor : inactiveColor,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getTranslatedLevel(context, level),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? activeColor : inactiveColor,
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