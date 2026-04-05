import 'package:between_pages/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;
  final Ref _ref;

  // Empezamos con "data(null)" porque al abrir la app no estamos cargando nada ni hay error.
  AuthController(this._authRepository, this._ref) : super(const AsyncValue.data(null));

  // Método para iniciar sesión.
  Future<void> login(String email, String password) async {
    // Ponemos el estado en "loading".
    state = const AsyncValue.loading();
    try {
      await _authRepository.login(email, password);
      // Avisamos a la app de que el estado de sesión ha cambiado
      _ref.invalidate(isLoggedInProvider);
      // Volvemos a poner el estado en "data" (Éxito).
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      // Ponemos el estado en "error" (Error).
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Método para registrar usuario.
  Future<void> register(String name, String email, String password) async {
    // Ponemos el estado en "loading".
    state = const AsyncValue.loading();
    try {
      await _authRepository.register(name, email, password);
      // Volvemos a poner el estado en "data" (Éxito).
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      // Ponemos el estado en "error" (Error).
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Método para cerrar sesión.
  Future<void> logout() async {
    try {
      await _authRepository.logout();
      // Avisamos a la app de que el estado de sesión ha cambiado
      _ref.invalidate(isLoggedInProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Creamos el proveedor de Riverpod para poder usar este controlador en cualquier pantalla.
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      return AuthController(ref.watch(authRepositoryProvider), ref);
    });

// Proveedor para verificar si el usuario está logueado o no (sesión activa).
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return await authRepository.isLoggedIn();
});
