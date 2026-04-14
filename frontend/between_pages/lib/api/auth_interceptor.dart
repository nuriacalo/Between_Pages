import 'package:between_pages/api/auth_token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthInterceptor extends Interceptor {
  final AuthTokenStorage _authTokenStorage;

  AuthInterceptor(this._authTokenStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Leemos el token
    final token = await _authTokenStorage.readToken();

    if (kDebugMode) {
      print('[AuthInterceptor] ${options.uri}');
      print(
        '[AuthInterceptor] Token exists: ${token != null && token.isNotEmpty}',
      );
    }

    // Si existe, lo inyectamos en el header de la petición
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      final statusCode = err.response?.statusCode;
      if (statusCode != null) {
        print('[AuthInterceptor] Error $statusCode: ${err.requestOptions.uri}');
      } else {
        print(
          '[AuthInterceptor] Network error (${err.type}): ${err.message} -> ${err.requestOptions.uri}',
        );
      }
    }

    // Si recibimos un error 401 (Unauthorized) o 403 (Forbidden), el token no es válido, ha expirado o hubo conflicto de permisos
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      // Eliminamos el token almacenado
      await _authTokenStorage.removeToken();
    }

    return super.onError(err, handler);
  }
}
