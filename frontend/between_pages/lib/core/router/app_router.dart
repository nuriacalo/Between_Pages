import 'package:between_pages/controllers/auth_controller.dart';
import 'package:between_pages/screens/auth/login_page.dart';
import 'package:between_pages/screens/auth/register_page.dart';
import 'package:between_pages/screens/home/book_detail_page.dart';
import 'package:between_pages/screens/home/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:between_pages/models/catalog/book_response_dto.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // Ruta en la que arranca la app
    initialLocation: '/',
    // Notificamos a GoRouter cada vez que el estado cambie
    refreshListenable: _GoRouterNotifier(ref),
    redirect: (context, state) {
      // Usamos ref.read en lugar de ref.watch para evitar reconstruir todo el router
      final authState = ref.read(isLoggedInProvider);
      final isLoggedIn = authState.valueOrNull ?? false;
      
    // Verificamos si intenta ir a CUALQUIER pantalla de autenticación
      final isGoingToAuth = state.uri.toString() == '/login' || state.uri.toString() == '/register';

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
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
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
    ],
  );

});

// Clase auxiliar que avisa a GoRouter cuando cambia la sesión
class _GoRouterNotifier extends ChangeNotifier {
  _GoRouterNotifier(Ref ref) {
    ref.listen(isLoggedInProvider, (_, _) => notifyListeners());
  }
}