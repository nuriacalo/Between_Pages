import 'package:between_pages/features/auth/application/controllers/auth_controller.dart';
import 'package:between_pages/features/auth/presentation/pages/login_page.dart';
import 'package:between_pages/features/auth/presentation/pages/register_page.dart';
import 'package:between_pages/features/catalog/presentation/pages/catalog_detail_page.dart';
import 'package:between_pages/features/home/presentation/pages/home_page.dart';
import 'package:between_pages/features/journal/domain/book_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/fanfic_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/domain/manga_journal_response_dto.dart';
import 'package:between_pages/features/journal/presentation/pages/journal_item_edit_page.dart';
import 'package:between_pages/features/journal/presentation/pages/book_reading_progress_page.dart';
import 'package:between_pages/features/journal/presentation/pages/diary_page.dart';
import 'package:between_pages/features/journal/presentation/pages/universal_session_page.dart';
import 'package:between_pages/features/lists/presentation/pages/reading_lists_page.dart';
import 'package:between_pages/features/profile/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _GoRouterNotifier(ref),
    redirect: (context, state) {
      final authState = ref.read(isLoggedInProvider);
      final isGoingToAuth =
          state.uri.toString() == '/login' ||
          state.uri.toString() == '/register';
      final isLoggedIn = authState.when(
        data: (loggedIn) => loggedIn,
        loading: () => null,
        error: (_, _) => false,
      );
      if (isLoggedIn == null) return null;
      if (!isLoggedIn && !isGoingToAuth) return '/login';
      if (isLoggedIn && isGoingToAuth) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/item/:type/:id',
        builder: (context, state) {
          final type = state.pathParameters['type']!;
          final item = state.extra as dynamic;
          final itemType = CatalogItemType.values.firstWhere((e) => e.toString() == 'CatalogItemType.$type');
          return CatalogDetailPage(item: item, type: itemType);
        },
      ),
      GoRoute(
        path: '/journal/book/edit',
        builder: (context, state) {
          final journal = state.extra as BookJournalResponseDto;
          return JournalItemEditPage(journal: journal, type: JournalType.book);
        },
      ),
      GoRoute(
        path: '/journal/book/progress',
        builder: (context, state) {
          final journal = state.extra as BookJournalResponseDto;
          return BookReadingProgressPage(journal: journal);
        },
      ),
      GoRoute(
        path: '/journal/book/session',
        builder: (context, state) {
          final journal = state.extra as BookJournalResponseDto;
          return UniversalSessionPage(data: journal.toSessionData());
        },
      ),
      GoRoute(
        path: '/journal/book/diary',
        builder: (context, state) {
          final journal = state.extra as BookJournalResponseDto;
          return DiaryPage(data: journal.toDiaryData());
        },
      ),
      GoRoute(
        path: '/journal/manga/edit',
        builder: (context, state) {
          final journal = state.extra as MangaJournalResponseDTO;
          return JournalItemEditPage(journal: journal, type: JournalType.manga);
        },
      ),
      GoRoute(
        path: '/journal/fanfic/edit',
        builder: (context, state) {
          final journal = state.extra as FanficJournalResponseDTO;
          return JournalItemEditPage(journal: journal, type: JournalType.fanfic);
        },
      ),
      GoRoute(
        path: '/journal/manga/diary',
        builder: (context, state) {
          final journal = state.extra as MangaJournalResponseDTO;
          return DiaryPage(data: journal.toDiaryData());
        },
      ),
      GoRoute(
        path: '/journal/fanfic/diary',
        builder: (context, state) {
          final journal = state.extra as FanficJournalResponseDTO;
          return DiaryPage(data: journal.toDiaryData());
        },
      ),
      GoRoute(
        path: '/journal/manga/session',
        builder: (context, state) {
          final journal = state.extra as MangaJournalResponseDTO;
          return UniversalSessionPage(data: journal.toSessionData());
        },
      ),
      GoRoute(
        path: '/journal/fanfic/session',
        builder: (context, state) {
          final journal = state.extra as FanficJournalResponseDTO;
          return UniversalSessionPage(data: journal.toSessionData());
        },
      ),
      GoRoute(
        path: '/lists',
        builder: (context, state) => const ReadingListsPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
});

class _GoRouterNotifier extends ChangeNotifier {
  _GoRouterNotifier(Ref ref) {
    ref.listen(isLoggedInProvider, (_, _) => notifyListeners());
  }
}
