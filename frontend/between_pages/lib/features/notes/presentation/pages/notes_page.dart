import 'package:between_pages/core/theme/app_colors.dart';
import 'package:between_pages/features/notes/presentation/widget/notes_tab.dart';
import 'package:flutter/material.dart';

class NotesPage extends StatelessWidget {
  final String itemType; // 'BOOK' | 'MANGA' | 'FANFIC'
  final int    itemId;

  const NotesPage({
    super.key,
    required this.itemType,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation:       0,
        foregroundColor: AppColors.accent(context),
        title: Text(
          'Notas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color:      colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: NotesTab(itemType: itemType, itemId: itemId),
      ),
    );
  }
}