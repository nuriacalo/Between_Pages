import 'package:between_pages/features/profile/application/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diseño y Ajustes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Apariencia', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Tema de la Aplicación'),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) notifier.updateTheme(newValue);
              },
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('Sistema')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Claro')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Oscuro')),
              ],
            ),
          ),
          const Divider(height: 32),
          Text('Tipografía', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.font_download_outlined),
            title: const Text('Fuente de lectura e interfaz'),
            subtitle: const Text('Elige cómo verás tus notas'),
            trailing: DropdownButton<String>(
              value: settings.fontFamily,
              onChanged: (String? newValue) {
                if (newValue != null) notifier.updateFont(newValue);
              },
              items: const [
                DropdownMenuItem(value: 'Roboto', child: Text('Roboto (Moderna)')),
                DropdownMenuItem(value: 'Lora', child: Text('Lora (Clásica/Libro)')),
                DropdownMenuItem(value: 'OpenSans', child: Text('Open Sans')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Preview visual
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vista previa:', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 8),
                  Text(
                    '«Un lector vive mil vidas antes de morir. El que nunca lee solo vive una.»',
                    style: TextStyle(fontFamily: settings.fontFamily, fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}