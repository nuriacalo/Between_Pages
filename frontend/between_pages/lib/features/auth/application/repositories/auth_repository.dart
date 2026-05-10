import 'package:between_pages/core/api/api_client.dart';
import 'package:between_pages/core/api/auth_token_storage.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/features/auth/application/providers/api_provider.dart';
import 'package:between_pages/features/profile/domain/user_response_dto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

/// Repositorio encargado de toda la lógica de autenticación:
/// login, registro, logout, refresh de tokens y verificación de sesión.
class AuthRepository {
  final ApiClient _apiClient;
  final AuthTokenStorage _authTokenStorage;

  AuthRepository(this._apiClient, this._authTokenStorage);

  /// Inicia sesión y almacena tanto accessToken como refreshToken de forma segura.
  Future<void> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final accessToken = response.data['accessToken'] as String?;
      final refreshToken = response.data['refreshToken'] as String?;

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception(
          'Token no encontrado. El servidor devolvió: ${response.data}',
        );
      }

      await _authTokenStorage.saveToken(accessToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _authTokenStorage.saveRefreshToken(refreshToken);
      }
    } on DioException catch (e) {
      debugPrint('⚠️ Error 400 Body: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Error al iniciar sesión: ${e.message}',
      );
    }
  }

  /// Intenta renovar el accessToken usando el refreshToken almacenado.
  /// Retorna true si tuvo éxito, false en caso contrario.
  Future<bool> refreshAccessToken() async {
    final refreshToken = await _authTokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await _apiClient.post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['accessToken'] as String?;
      final newRefreshToken = response.data['refreshToken'] as String?;

      if (newAccessToken == null || newAccessToken.isEmpty) {
        return false;
      }

      await _authTokenStorage.saveToken(newAccessToken);
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await _authTokenStorage.saveRefreshToken(newRefreshToken);
      }
      return true;
    } on DioException catch (_) {
      await _authTokenStorage.clearAll();
      return false;
    } catch (_) {
      await _authTokenStorage.clearAll();
      return false;
    }
  }

  /// Registra un nuevo usuario.
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

  /// Cierra sesión eliminando todos los tokens de forma segura.
  Future<void> logout() async {
    await _authTokenStorage.clearAll();
  }

  /// Obtiene el perfil del usuario autenticado.
  Future<UserResponseDTO> getUserProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.me);
      return UserResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error al obtener perfil: ${e.message}');
    }
  }

  /// Verifica si hay una sesión activa. Si el accessToken falla,
  /// intenta automáticamente un refresh antes de dar por terminada la sesión.
  Future<bool> isLoggedIn() async {
    final token = await _authTokenStorage.readToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      await _apiClient.get(ApiConstants.me);
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          // Reintentar una vez con el nuevo token
          try {
            await _apiClient.get(ApiConstants.me);
            return true;
          } catch (_) {
            await _authTokenStorage.clearAll();
            return false;
          }
        }
      }
      await _authTokenStorage.clearAll();
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Stream que notifica cuando el token cambia (para redirección automática).
  Stream<void> get onTokenChanged => _authTokenStorage.onTokenChanged;
}

/// Provider del repositorio de autenticación.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(authTokenStorageProvider),
  );
});
