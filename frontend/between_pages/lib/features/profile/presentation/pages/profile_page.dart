import 'package:between_pages/core/providers/locale_provider.dart';
import 'package:between_pages/core/providers/theme_provider.dart';
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
    final currentLocale = ref.watch(localeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final themeNotifier = ref.watch(themeProvider.notifier);
    final isDarkMode = themeNotifier.isDark;

    final userProfileAsync = ref.watch(userProfileProvider);
    final authState = ref.watch(authControllerProvider);
    final allJournals = ref.watch(allJournalsProvider);

    final finishedBooks = allJournals.whenOrNull(data: (j) =>
        j[JournalType.book]?.where((item) => item.status == 'FINISHED').length) ?? 0;
    final finishedMangas = allJournals.whenOrNull(data: (j) =>
        j[JournalType.manga]?.where((item) => item.status == 'FINISHED').length) ?? 0;
    final finishedFanfics = allJournals.whenOrNull(data: (j) =>
        j[JournalType.fanfic]?.where((item) => item.status == 'FINISHED').length) ?? 0;


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
        elevation: 0,
      ),
      backgroundColor: colorScheme.surface,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- User Info Header ---
          const SizedBox(height: 16),
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 16),
          if (userProfileAsync.valueOrNull != null) ...[
            Text(
              userProfileAsync.value!.name,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              userProfileAsync.value!.email,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ] else if (userProfileAsync.isLoading)
            const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 32),
                // --- Estadísticas ---
                Text('Estadísticas', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.0,
                  ),
                  children: [
                    _StatCard(icon: Icons.book_rounded, label: 'Libros', value: '$finishedBooks', color: const Color(0xFF7F8C95)),
                    _StatCard(icon: Icons.menu_book_rounded, label: 'Mangas', value: '$finishedMangas', color: const Color(0xFFE8A87C)),
                    _StatCard(icon: Icons.favorite_rounded, label: 'Fanfics', value: '$finishedFanfics', color: const Color(0xFFD4A0A4)),
                  ],
                ),
                const SizedBox(height: 24),

                // --- Cuenta ---
                Text(l10n.profileAccount, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(l10n.profileEditProfile),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/profile/edit'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.list_alt_rounded),
                        title: const Text('Mis Listas'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/lists'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- Ajustes ---
                Text(l10n.profileSettings, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
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
                          onChanged: (value) => themeNotifier.toggle(),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.notifications_outlined),
                        title: Text(l10n.profileNotifications),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // --- Logout ---
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.errorContainer,
                    foregroundColor: colorScheme.onErrorContainer,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.profileLogout),
                  onPressed: authState.isLoading ? null : () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 6),
          Text(value, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
          Text(label, style: textTheme.labelSmall?.copyWith(color: color.withOpacity(0.8))),
        ],
      ),
    );
  }
}