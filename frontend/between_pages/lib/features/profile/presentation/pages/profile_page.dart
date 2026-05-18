import 'package:between_pages/core/providers/locale_provider.dart';
import 'package:between_pages/core/providers/theme_provider.dart';
import 'package:between_pages/features/auth/application/controllers/auth_controller.dart';
import 'package:between_pages/features/profile/application/providers/annual_goal_provider.dart';
import 'package:between_pages/features/profile/application/providers/user_provider.dart';
import 'package:between_pages/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  void _showGoalDialog(BuildContext context, WidgetRef ref, AnnualGoal currentGoal) {
    final controller = TextEditingController(text: currentGoal.target.toString());
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.editGoal),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.setYourGoal),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancelButton),
            ),
            FilledButton(
              onPressed: () {
                final newTarget = int.tryParse(controller.text);
                if (newTarget != null) {
                  ref.read(annualGoalProvider.notifier).setGoal(newTarget);
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.saveButton),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final currentLocale = ref.watch(localeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final themeNotifier = ref.watch(themeProvider.notifier);
    final isDarkMode = themeNotifier.isDark;

    final userProfileAsync = ref.watch(userProfileProvider);
    final authState = ref.watch(authControllerProvider);
    final annualGoalAsync = ref.watch(annualGoalProvider);

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
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
      appBar: AppBar(
        title: Text(
          l10n.profileTitle,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.surface,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 32),
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 16),

          userProfileAsync.when(
            data: (user) => Column(
              children: [
                Text(user.name, textAlign: TextAlign.center, style: textTheme.titleLarge),
                Text(user.email, textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Error: $error'),
          ),
          const SizedBox(height: 32),

          annualGoalAsync.when(
            data: (goal) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                child: InkWell(
                  onTap: () => _showGoalDialog(context, ref, goal),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.show_chart, size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.annualGoal, style: textTheme.titleMedium),
                              Text('${goal.completed} / ${goal.target} ${l10n.booksRead}'),
                            ],
                          ),
                        ),
                        CircularProgressIndicator(value: goal.target > 0 ? goal.completed / goal.target : 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Error: $error'),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(l10n.profileAccount, style: textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.profileEditProfile),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile/edit'),
          ),

          const Divider(),

          ListTile(
            leading: Icon(Icons.list, color: colorScheme.primary),
            title: const Text('Mis Listas'),
            subtitle: const Text('Ver y gestionar tus listas de lectura'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/lists'),
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(l10n.profileSettings, style: textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.profileLanguage),
            trailing: DropdownButton<String>(
              value: currentLocale.languageCode,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'es', child: Text('Español')),
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'gl', child: Text('Galego')),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(newValue));
                }
              },
            ),
          ),
          ListTile(
            leading: Icon(isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
            title: Text(l10n.profileDarkMode),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                themeNotifier.toggle();
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(l10n.profileNotifications),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: Text(l10n.profilePrivacy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const Divider(),

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.errorContainer,
                foregroundColor: colorScheme.onErrorContainer,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.logout),
              label: Text(l10n.profileLogout),
              onPressed: authState.isLoading ? null : () => ref.read(authControllerProvider.notifier).logout(),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}