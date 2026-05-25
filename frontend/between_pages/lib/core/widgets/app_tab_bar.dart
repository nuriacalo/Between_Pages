// lib/core/widgets/app_tab_bar.dart

import 'package:between_pages/core/theme/app_colors.dart';
import 'package:between_pages/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class AppTabBar extends StatelessWidget {
  final TabController controller;
  final Color accent;
  final AppLocalizations l10n;

  const AppTabBar({
    super.key,
    required this.controller,
    required this.accent,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      labelColor: accent,
      unselectedLabelColor: AppColors.textSecondary(context),
      indicatorColor: accent,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorWeight: 3,
      dividerColor: AppColors.border(context),
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      tabs: [
        Tab(text: l10n.tabBooks),
        Tab(text: l10n.tabMangas),
        Tab(text: l10n.tabFanfics),
      ],
    );
  }
}