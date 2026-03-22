// lib/features/catalog/screens/fanfic_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class FanficScreen extends StatelessWidget {
  const FanficScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Fanfic — próximamente',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}