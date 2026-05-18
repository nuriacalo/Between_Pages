import 'package:between_pages/features/catalog/presentation/pages/catalog_page.dart';
import 'package:between_pages/features/journal/presentation/pages/journal_page.dart';
import 'package:between_pages/features/library/presentation/pages/feed_page.dart';
import 'package:between_pages/features/profile/presentation/pages/profile_page.dart';
import 'package:between_pages/features/search/presentation/pages/search_page.dart';
import 'package:between_pages/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';

// TODO: Create a provider to track the last interacted book/journal item.
// For now, we'll use a placeholder.
final lastReadItemProvider = StateProvider<dynamic>((ref) => null);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  void _startReadingSession() {
    final lastReadItem = ref.read(lastReadItemProvider);
    final context = this.context; // Capture context
    final l10n = AppLocalizations.of(context)!;

    if (lastReadItem != null && lastReadItem.toSessionData != null) {
      // We have a last-read item, navigate to the session page
      GoRouter.of(context).go('/journal/${lastReadItem.type}/session', extra: lastReadItem);
    } else {
      // No last-read item found, guide the user.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.findSomethingToRead),
          duration: Duration(seconds: 3),
        ),
      );
      // Optionally, navigate to the journal page
      setState(() {
        _selectedIndex = 3; // Index for JournalPage
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final screens = [
      const FeedPage(),
      const SearchPage(),
      const CatalogPage(),
      const JournalPage(),
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
          NavigationDestination(icon: const Icon(Icons.home), label: l10n.homeTitle),
          NavigationDestination(icon: const Icon(Icons.search), label: l10n.searchTitle),
          NavigationDestination(icon: const Icon(Icons.library_books), label: l10n.catalogTitle),
          NavigationDestination(icon: const Icon(Icons.book), label: l10n.journalTitle),
          NavigationDestination(icon: const Icon(Icons.person), label: l10n.profileTitle),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? null
          : SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        spacing: 12,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.timer),
            label: l10n.startReadingSession,
            onTap: _startReadingSession,
          ),
          SpeedDialChild(
            child: const Icon(Icons.note_add),
            label: l10n.editJournal,
            onTap: () {
              // Navigate to the notes page. It requires a bookId, so we can't go
              // directly without more context. For now, we can show a message.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.findSomethingToRead)),
              );
               setState(() {
                _selectedIndex = 3; // Navigate to JournalPage
              });
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.book_online),
            label: l10n.searchTitle,
            onTap: () {
              // Navigate to the search page to find and add a book
              setState(() {
                _selectedIndex = 1; // Navigate to SearchPage
              });
            },
          ),
        ],
      ),
    );
  }
}