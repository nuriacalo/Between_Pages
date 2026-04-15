import 'package:between_pages/api/api_client.dart';
import 'package:between_pages/api/auth_token_storage.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/providers/auth/api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:between_pages/models/user/user_response_dto.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final AuthTokenStorage _authTokenStorage;

  AuthRepository(this._apiClient, this._authTokenStorage);

  // Iniciar sesión
  Future<void> login(String email, String password) async {
    try {
      //P¡ Post a la ruta de login
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      // Guardar el token de autenticación
      final token = response.data['accessToken'];
      if (token != null) {
        await _authTokenStorage.saveToken(token);
      } else {
        throw Exception(
          'Token no encontrado. El servidor devolvió: ${response.data}',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error al iniciar sesión: ${e.message}',
      );
    }
  }

  // Registrar usuario
  Future<void> register(String name, String email, String password) async {
    try {
      await _apiClient.post(
        ApiConstants.userRegister,
        data: {'name': name, 'email': email, 'password': password},
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Error al registrar usuario: ${e.message}',
      );
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _authTokenStorage.removeToken();
  }

  // Obtener perfil del usuario autenticado
  Future<UserResponseDTO> getUserProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.me);
      // Transformamos el JSON al modelo que ya tienes creado
      return UserResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error al obtener perfil: ${e.message}');
    }
  }

  // Verificar si hay un token válido (sesión activa)
  Future<bool> isLoggedIn() async {
    final token = await _authTokenStorage.readToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    // Verificar que el token sea válido haciendo una petición al backend
    try {
      await _apiClient.get(ApiConstants.me);
      return true;
    } on DioException catch (e) {
      // Si el token es inválido o expiró, eliminarlo
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        await _authTokenStorage.removeToken();
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // Stream que notifica cuando el token cambia (para redirección automática)
  Stream<void> get onTokenChanged => _authTokenStorage.onTokenChanged;
}

//Proveedor del repositorio
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(authTokenStorageProvider),
  );
});
