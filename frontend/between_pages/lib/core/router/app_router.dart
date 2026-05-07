import 'package:between_pages/controllers/auth_controller.dart';
import 'package:between_pages/models/catalog/book_response_dto.dart';
import 'package:between_pages/models/catalog/manga_response_dto.dart';
import 'package:between_pages/models/catalog/fanfiction_response_dto.dart';
import 'package:between_pages/models/journal/book_journal_response_dto.dart';
import 'package:between_pages/models/journal/manga_journal_response_dto.dart';
import 'package:between_pages/models/journal/fanfic_journal_response_dto.dart';
import 'package:between_pages/screens/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:between_pages/screens/auth/register_page.dart';
import 'package:between_pages/screens/catalog/catalog_detail_page.dart';
import 'package:between_pages/screens/home/home_page.dart';
import 'package:between_pages/screens/journal/book_journal_edit_page.dart';
import 'package:between_pages/screens/journal/book_reading_progress_page.dart';
import 'package:between_pages/screens/journal/diary_page.dart';
import 'package:between_pages/screens/journal/fanfic_journal_edit_page.dart';
import 'package:between_pages/screens/journal/manga_journal_edit_page.dart';
import 'package:between_pages/screens/journal/universal_session_page.dart';
import 'package:between_pages/repositories/journal_mappers.dart';
import 'package:between_pages/screens/lists/reading_lists_page.dart';
import 'package:between_pages/screens/profile/settings_page.dart';
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
        path: '/book/:id',
        builder: (context, state) {
          final book = state.extra as BookResponseDTO;
          return CatalogDetailPage(item: book, type: CatalogItemType.book);
        },
      ),
      GoRoute(
        path: '/manga/:id',
        builder: (context, state) {
          final manga = state.extra as MangaResponseDTO;
          return CatalogDetailPage(item: manga, type: CatalogItemType.manga);
        },
      ),
      GoRoute(
        path: '/fanfic/:id',
        builder: (context, state) {
          final fanfic = state.extra as FanfictionResponseDTO;
          return CatalogDetailPage(item: fanfic, type: CatalogItemType.fanfic);
        },
      ),
      GoRoute(
        path: '/journal/book/edit',
        builder: (context, state) {
          final journal = state.extra as BookJournalResponseDto;
          return BookJournalEditPage(journal: journal);
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
          return MangaJournalEditPage(journal: journal);
        },
      ),
      GoRoute(
        path: '/journal/fanfic/edit',
        builder: (context, state) {
          final journal = state.extra as FanficJournalResponseDTO;
          return FanficJournalEditPage(journal: journal);
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
