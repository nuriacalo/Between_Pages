import 'package:between_pages/feed_page.dart';
import 'package:between_pages/l10n/app_localizations.dart';
import 'package:between_pages/screens/journal/journal_page.dart';
import 'package:between_pages/screens/search/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:between_pages/screens/profile/profile_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Aquí definiremos las distintas pantallas de la app.
    final screens = [
      // Pantalla de Inicio (Lecturas en progreso)
      const FeedPage(),
      // Pantalla de Búsqueda
      const SearchPage(),
      // Pantalla de Journal (Antes FeedPage, tu biblioteca completa)
      const JournalPage(),
      // Pantalla de Perfil
      const ProfilePage(),
    ];

    // Títulos dinámicos según la pestaña seleccionada
    final titles = [
      l10n.homeTitle,
      l10n.searchTitle,
      'Journal', // TODO: Añadir este texto a tus archivos .arb de traducciones
      l10n.profileTitle,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home), label: l10n.homeTitle),
          NavigationDestination(icon: const Icon(Icons.search), label: l10n.searchTitle),
          const NavigationDestination(icon: Icon(Icons.book), label: 'Journal'),
          NavigationDestination(icon: const Icon(Icons.person), label: l10n.profileTitle),
        ],
      ),
    );
  }
}
