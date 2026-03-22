// lib/features/catalog/screens/manga_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class MangaScreen extends StatelessWidget {
  const MangaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Manga — próximamente',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}