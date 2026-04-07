import 'package:between_pages/api/api_client.dart';
import 'package:between_pages/api/auth_token_storage.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/providers/api_provider.dart';
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
        throw Exception('Token no encontrado. El servidor devolvió: ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al iniciar sesión: ${e.message}');
    }
  }

  // Registrar usuario
  Future<void> register(String name, String email, String password) async {
    try {
      await _apiClient.post(
        ApiConstants.usuarioRegistrar,
        data: {'name': name, 'email': email, 'password': password},
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error al registrar usuario: ${e.message}',
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

  // Verificar si hay un token guardado (sesión activa)
  Future<bool> isLoggedIn() async {
    final token = await _authTokenStorage.readToken();
    return token != null && token.isNotEmpty;
  }
}

//Proveedor del repositorio
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(authTokenStorageProvider),
  );
});
