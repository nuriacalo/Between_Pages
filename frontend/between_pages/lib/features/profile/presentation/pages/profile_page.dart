import 'package:between_pages/core/providers/locale_provider.dart';
import 'package:between_pages/core/providers/theme_provider.dart';
import 'package:between_pages/core/theme/app_colors.dart';
import 'package:between_pages/features/auth/application/controllers/auth_controller.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/profile/application/providers/user_provider.dart';
import 'package:between_pages/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final currentLocale = ref.watch(localeProvider);
    final themeNotifier = ref.watch(themeProvider.notifier);
    final isDarkMode = themeNotifier.isDark;
    final userProfileAsync = ref.watch(userProfileProvider);
    final authState = ref.watch(authControllerProvider);
    final allJournals = ref.watch(allJournalsProvider);

    final finishedBooks =
        allJournals.whenOrNull(
          data: (j) => j[JournalType.book]
              ?.where((item) => item.status == 'FINISHED')
              .length,
        ) ??
        0;

    final finishedMangas =
        allJournals.whenOrNull(
          data: (j) => j[JournalType.manga]
              ?.where((item) => item.status == 'FINISHED')
              .length,
        ) ??
        0;

    final finishedFanfics =
        allJournals.whenOrNull(
          data: (j) => j[JournalType.fanfic]
              ?.where((item) => item.status == 'FINISHED')
              .length,
        ) ??
        0;

    final totalFinished = finishedBooks + finishedMangas + finishedFanfics;

    ref.listen(authControllerProvider, (_, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cerrar sesión: $error'),
              backgroundColor: colorScheme.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            backgroundColor: AppColors.surface(context),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _ProfileHero(
                userAsync: userProfileAsync,
                textTheme: textTheme,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  const _SectionHeader(title: 'Estadísticas'),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.book_rounded,
                          label: 'Libros',
                          value: finishedBooks,
                          total: totalFinished,
                          color: AppColors.colorLibro,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _StatCard(
                          icon: Icons.menu_book_rounded,
                          label: 'Mangas',
                          value: finishedMangas,
                          total: totalFinished,
                          color: AppColors.colorManga,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _StatCard(
                          icon: Icons.favorite_rounded,
                          label: 'Fanfics',
                          value: finishedFanfics,
                          total: totalFinished,
                          color: AppColors.colorFanfic,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _SectionHeader(title: l10n.profileAccount),
                  const SizedBox(height: 10),

                  _GroupCard(
                    children: [
                      _GroupTile(
                        icon: Icons.person_outline_rounded,
                        title: l10n.profileEditProfile,
                        onTap: () => context.push('/profile/edit'),
                      ),

                      _GroupTile(
                        icon: Icons.list_alt_rounded,
                        title: 'Mis listas',
                        onTap: () => context.push('/lists'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _SectionHeader(title: l10n.profileSettings),
                  const SizedBox(height: 10),

                  _GroupCard(
                    children: [
                      _GroupTile(
                        icon: Icons.language_rounded,
                        title: l10n.profileLanguage,
                        trailing: _DropdownTrailing(
                          value: currentLocale.languageCode,
                          items: const {
                            'es': 'Español',
                            'en': 'English',
                            'gl': 'Galego',
                          },
                          onChanged: (v) {
                            if (v != null) {
                              ref
                                  .read(localeProvider.notifier)
                                  .setLocale(Locale(v));
                            }
                          },
                        ),
                      ),

                      _GroupTile(
                        icon: isDarkMode
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        title: l10n.profileDarkMode,
                        trailing: Switch(
                          value: isDarkMode,
                          onChanged: (_) => themeNotifier.toggle(),
                          activeThumbColor: AppColors.accent(context),
                        ),
                      ),

                      _GroupTile(
                        icon: Icons.notifications_outlined,
                        title: l10n.profileNotifications,
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _GroupCard(
                    children: [
                      _GroupTile(
                        icon: Icons.logout_rounded,
                        title: l10n.profileLogout,
                        iconColor: AppColors.logout(context),
                        titleColor: AppColors.logout(context),
                        onTap: authState.isLoading
                            ? null
                            : () => ref
                                  .read(authControllerProvider.notifier)
                                  .logout(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final AsyncValue userAsync;
  final TextTheme textTheme;

  const _ProfileHero({required this.userAsync, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    final user = userAsync.valueOrNull;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(context),
        border: Border(
          bottom: BorderSide(color: AppColors.border(context), width: 1),
        ),
      ),
      padding: const EdgeInsets.only(top: 32, bottom: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent(context).withValues(alpha: 0.12),
              border: Border.all(color: AppColors.border(context), width: 1.5),
            ),
            child: Icon(
              Icons.person_rounded,
              size: 46,
              color: AppColors.accent(context),
            ),
          ),

          const SizedBox(height: 14),

          if (userAsync.isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent(context),
              ),
            )
          else if (user != null) ...[
            Text(
              user.name,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              user.email,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.accent(context),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final int total;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final progress = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: color),

          const SizedBox(height: 6),

          Text(
            '$value',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: color.withValues(alpha: 0.8),
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final List<Widget> children;

  const _GroupCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                indent: 52,
                endIndent: 16,
                color: AppColors.border(context),
              ),
          ],
        ],
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _GroupTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final resolvedIconColor = iconColor ?? AppColors.accent(context);

    final resolvedTitleColor = titleColor ?? AppColors.textPrimary(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: resolvedIconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: resolvedIconColor),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  color: resolvedTitleColor,
                ),
              ),
            ),

            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textSecondary(context),
                ),
          ],
        ),
      ),
    );
  }
}

class _DropdownTrailing extends StatelessWidget {
  final String value;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownTrailing({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.accent(
            context,
          ).withValues(alpha: 0.08), //FIX: Changed border radius from 6 to 8
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.accent(
              context,
            ).withValues(alpha: 0.3).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              items[value] ?? value,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.accent(context),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(width: 4),

            Icon(
              Icons.expand_more_rounded,
              size: 14,
              color: AppColors.accent(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(
        //FIX: Changed border radius from 12 to 20
        borderRadius: BorderRadius.circular(20),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),

            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 16),

            ...items.entries.map(
              (e) => ListTile(
                title: Text(e.value),
                trailing: e.key == value
                    ? Icon(
                        Icons.check_rounded,
                        color: AppColors.accent(context),
                      )
                    : null,
                onTap: () {
                  Navigator.of(context).pop();
                  onChanged(e.key);
                },
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
