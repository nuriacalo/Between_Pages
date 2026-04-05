import 'package:between_pages/controllers/auth_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:between_pages/providers/locale_provider.dart';
import 'package:between_pages/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final currentLocale = ref.watch(localeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Escuchamos el estado del perfil del usuario
    final userProfileAsync = ref.watch(userProfileProvider);

    return ListView(
      children: [
        const SizedBox(height: 32),
        const CircleAvatar(
          radius: 50,
          child: Icon(Icons.person, size: 50),
        ),
        const SizedBox(height: 16),
        
        // Mostramos los datos reales del usuario o un indicador de carga
        userProfileAsync.when(
          data: (user) => Column(
            children: [
              Text(user.nombre, textAlign: TextAlign.center, style: textTheme.titleLarge),
              Text(
                user.email,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error al cargar datos', textAlign: TextAlign.center, style: TextStyle(color: colorScheme.error)),
        ),
        const SizedBox(height: 32),

        // SECCIÓN: CUENTA
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            l10n.profileAccount,
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text(l10n.profileEditProfile),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navegar a la pantalla de Editar Perfil
          },
        ),

        const Divider(),

        // SECCIÓN: CONFIGURACIÓN
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            l10n.profileSettings,
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
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

        // SECCIÓN: ACCIONES
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
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
