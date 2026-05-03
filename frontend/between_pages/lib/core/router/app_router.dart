import 'package:between_pages/controllers/auth_controller.dart';
import 'package:between_pages/models/catalog/book_response_dto.dart';
import 'package:between_pages/models/catalog/manga_response_dto.dart';
import 'package:between_pages/models/journal/book_journal_response_dto.dart';
import 'package:between_pages/models/journal/manga_journal_response_dto.dart';
import 'package:between_pages/models/journal/fanfic_journal_response_dto.dart';
import 'package:between_pages/screens/auth/login_page.dart';
import 'package:between_pages/screens/auth/register_page.dart';
import 'package:between_pages/screens/catalog/catalog_detail_page.dart';
import 'package:between_pages/screens/home/home_page.dart';
import 'package:between_pages/screens/journal/book_journal_edit_page.dart';
import 'package:between_pages/screens/journal/book_reading_progress_page.dart';
import 'package:between_pages/screens/journal/fanfic_journal_edit_page.dart';
import 'package:between_pages/screens/journal/fanfic_reading_session_page.dart';
import 'package:between_pages/screens/journal/manga_journal_edit_page.dart';
import 'package:between_pages/screens/journal/reading_session_page.dart';
import 'package:between_pages/screens/journal/second_brain_page.dart';
import 'package:between_pages/screens/journal/ocr_scanner_page.dart';
import 'package:between_pages/screens/profile/settings_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // Ruta en la que arranca la app
    initialLocation: '/',
    // Notificamos a GoRouter cada vez que el estado cambie
    refreshListenable: _GoRouterNotifier(ref),
    redirect: (context, state) {
      // Usamos ref.read en lugar de ref.watch para evitar reconstruir todo el router
      final authState = ref.read(isLoggedInProvider);

      // Verificamos si intenta ir a CUALQUIER pantalla de autenticación
      final isGoingToAuth =
          state.uri.toString() == '/login' ||
          state.uri.toString() == '/register';

      // Esperamos a que el stream tenga datos
      final isLoggedIn = authState.when(
        data: (loggedIn) => loggedIn,
        loading: () => null, // Esperando, no redirigimos aún
        error: (_, _) => false, // En error, asumimos no logueado
      );

      // Si aún estamos cargando, no redirigimos
      if (isLoggedIn == null) return null;

      // Si NO está logueado y NO va a auth -> Lo obligamos a ir al login
      if (!isLoggedIn && !isGoingToAuth) {
        return '/login';
      }

      // Si SÍ está logueado pero intenta ir a auth -> Lo mandamos al inicio
      if (isLoggedIn && isGoingToAuth) {
        return '/';
      }

      // Si todo está bien, devuelve null (significa "déjalo pasar")
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
          return ReadingSessionPage(journal: journal);
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
        path: '/journal/fanfic/session',
        builder: (context, state) {
          final journal = state.extra as FanficJournalResponseDTO;
          return FanficReadingSessionPage(journal: journal);
        },
      ),
      GoRoute(
        path: '/second-brain',
        builder: (context, state) => const SecondBrainPage(),
      ),
      GoRoute(
        path: '/ocr-scanner',
        builder: (context, state) => const OcrScannerPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
});

// Clase auxiliar que avisa a GoRouter cuando cambia la sesión
class _GoRouterNotifier extends ChangeNotifier {
  _GoRouterNotifier(Ref ref) {
    ref.listen(isLoggedInProvider, (_, _) => notifyListeners());
  }
}
