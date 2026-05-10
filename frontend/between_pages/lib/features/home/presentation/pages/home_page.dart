import 'package:between_pages/features/catalog/presentation/pages/catalog_page.dart';
import 'package:between_pages/features/journal/presentation/pages/journal_page.dart';
import 'package:between_pages/features/library/presentation/pages/feed_page.dart';
import 'package:between_pages/features/profile/presentation/pages/profile_page.dart';
import 'package:between_pages/features/search/presentation/pages/search_page.dart';
import 'package:between_pages/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      // Catálogo general de obras
      const CatalogPage(),
      // Pantalla de Journal (tu biblioteca personal)
      const JournalPage(),
      // Pantalla de Perfil
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home),
            label: l10n.homeTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search),
            label: l10n.searchTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.library_books),
            label: l10n.catalogTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.book),
            label: l10n.journalTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person),
            label: l10n.profileTitle,
          ),
        ],
      ),
    );
  }
}
