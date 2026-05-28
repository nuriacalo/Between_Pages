import 'package:between_pages/core/api/api_client.dart';
import 'package:between_pages/core/api/auth_token_storage.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/features/auth/application/providers/api_provider.dart';
import 'package:between_pages/features/profile/domain/user_response_dto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

/// Excepción personalizada para errores de autenticación sin el prefijo "Exception:"
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

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
        throw AuthException(
          'Token no encontrado. El servidor devolvió: ${response.data}',
        );
      }

      await _authTokenStorage.saveToken(accessToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _authTokenStorage.saveRefreshToken(refreshToken);
      }
    } on DioException catch (e) {
      debugPrint('⚠️ Error 400 Body: ${e.response?.data}');
      final data = e.response?.data;
      String errorMsg = 'Error al iniciar sesión';
      if (data is Map && data['message'] != null) {
        errorMsg = data['message'].toString();
      } else if (data is String && data.trim().isNotEmpty) {
        errorMsg = data;
      } else if (e.message != null && e.message!.isNotEmpty) {
        errorMsg = '$errorMsg: ${e.message}';
      }
      throw AuthException(errorMsg);
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
      final data = e.response?.data;
      String errorMsg = 'Error al registrar usuario';
      if (data is Map && data['message'] != null) {
        errorMsg = data['message'].toString();
      } else if (data is String && data.trim().isNotEmpty) {
        errorMsg = data;
      } else if (e.message != null && e.message!.isNotEmpty) {
        errorMsg = '$errorMsg: ${e.message}';
      }
      throw AuthException(errorMsg);
    }
  }

  /// Cierra sesión eliminando todos los tokens de forma segura.
  Future<void> logout() async {
    await _authTokenStorage.clearAll();
  }

  /// Actualiza el perfil del usuario.
  Future<void> updateProfile(int userId, String name, String email) async {
    try {
      await _apiClient.put(
        '${ApiConstants.user}$userId',
        data: {'name': name, 'email': email},
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      String errorMsg = 'Error al actualizar perfil';
      if (data is Map && data['message'] != null) {
        errorMsg = data['message'].toString();
      } else if (data is String && data.trim().isNotEmpty) {
        errorMsg = data;
      } else if (e.message != null && e.message!.isNotEmpty) {
        errorMsg = '$errorMsg: ${e.message}';
      }
      throw AuthException(errorMsg);
    }
  }

  /// Obtiene el perfil del usuario autenticado.
  Future<UserResponseDTO> getUserProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.me);
      return UserResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      final msg = e.message != null && e.message!.isNotEmpty ? ': ${e.message}' : '';
      throw AuthException('Error al obtener perfil$msg');
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
