import 'package:between_pages/features/catalog/presentation/pages/catalog_page.dart';
import 'package:between_pages/features/journal/presentation/pages/journal_page.dart';
import 'package:between_pages/features/library/presentation/pages/feed_page.dart';
import 'package:between_pages/features/profile/presentation/pages/profile_page.dart';
import 'package:between_pages/features/search/presentation/pages/search_page.dart';
import 'package:between_pages/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Create a provider to track the last interacted book/journal item.
// For now, we'll use a placeholder.
final lastReadItemProvider = StateProvider<dynamic>((ref) => null);

// Proveedor para controlar la pestaña seleccionada en el BottomNavigationBar
final homeTabProvider = StateProvider<int>((ref) => 0);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final selectedIndex = ref.watch(homeTabProvider);

    final screens = [
      const FeedPage(),
      const SearchPage(),
      const CatalogPage(),
      const JournalPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.dividerColor.withValues(alpha:0.1),
              width: 1.0,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            ref.read(homeTabProvider.notifier).state = index;
          },
          destinations: [
            NavigationDestination(
                icon: const Icon(Icons.home), label: l10n.homeTitle),
            NavigationDestination(
                icon: const Icon(Icons.search), label: l10n.searchTitle),
            NavigationDestination(
                icon: const Icon(Icons.library_books),
                label: l10n.catalogTab),
            NavigationDestination(
                icon: const Icon(Icons.book), label: l10n.journalTitle),
            NavigationDestination(
                icon: const Icon(Icons.person), label: l10n.profileTitle),
          ],
        ),
      ),
    );
  }
}