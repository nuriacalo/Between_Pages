import 'package:between_pages/controllers/auth_controller.dart';
import 'package:between_pages/models/catalog/book_response_dto.dart';
import 'package:between_pages/models/catalog/manga_response_dto.dart';
import 'package:between_pages/models/journal/book_journal_response_dto.dart';
import 'package:between_pages/models/journal/manga_journal_response_dto.dart';
import 'package:between_pages/screens/auth/login_page.dart';
import 'package:between_pages/screens/auth/register_page.dart';
import 'package:between_pages/screens/detail/book_detail_page.dart';
import 'package:between_pages/screens/detail/manga_detail_page.dart';
import 'package:between_pages/screens/home/home_page.dart';
import 'package:between_pages/screens/journal/book_journal_edit_page.dart';
import 'package:between_pages/screens/journal/manga_journal_edit_page.dart';
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
        error: (_, __) => false, // En error, asumimos no logueado
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
          return BookDetailPage(book: book);
        },
      ),
      GoRoute(
        path: '/manga/:id',
        builder: (context, state) {
          final manga = state.extra as MangaResponseDTO;
          return MangaDetailPage(manga: manga);
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
        path: '/journal/manga/edit',
        builder: (context, state) {
          final journal = state.extra as MangaJournalResponseDTO;
          return MangaJournalEditPage(journal: journal);
        },
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
