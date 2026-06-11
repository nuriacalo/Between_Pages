import 'dart:collection';

import 'package:between_pages/core/api/auth_token_storage.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor que inyecta el token JWT en cada petición y maneja
/// renovación automática del token cuando recibe 401/403.
class AuthInterceptor extends Interceptor {
  final AuthTokenStorage _authTokenStorage;

  AuthInterceptor(this._authTokenStorage);

  /// Indica si ya se está intentando un refresh para evitar múltiples
  /// peticiones de refresh simultáneas.
  bool _isRefreshing = false;

  /// Cola de requests que esperan a que termine el refresh.
  final Queue<Function> _pendingRequests = Queue();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _authTokenStorage.readToken();

    if (kDebugMode) {
      print('[AuthInterceptor] ${options.method} ${options.uri}');
      print('[AuthInterceptor] Token exists: ${token != null && token.isNotEmpty}');
    }

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;

    if (kDebugMode) {
      if (statusCode != null) {
        print('[AuthInterceptor] Error $statusCode: ${err.requestOptions.uri}');
        final data = err.response?.data;
        if (data != null) {
          print('[AuthInterceptor] Error body: $data');
        }
      } else {
        print(
          '[AuthInterceptor] Network error (${err.type}): ${err.message} -> ${err.requestOptions.uri}',
        );
      }
    }

    // --- Lógica de renovación de token ---
    // Intentamos renovar el token en dos casos:
    // 1. Error 401 Unauthorized (token expirado o inválido).
    // 2. Error 403 Forbidden en el endpoint '/api/auth/me'. A veces, los backends
    //    devuelven 403 en lugar de 401 para tokens expirados. Lo tratamos como tal.
    if (statusCode == 401 || (statusCode == 403 && err.requestOptions.path.endsWith('/auth/me'))) {
      if (_isRefreshing) {
        // Esperar a que termine el refresh actual y reintentar
        _pendingRequests.add(() => _retryRequest(err, handler));
        return;
      }

      _isRefreshing = true;
      final refreshed = await _attemptRefresh();

      if (refreshed) {
        // Reintentar request original
        await _retryRequest(err, handler);

        // Procesar requests pendientes
        while (_pendingRequests.isNotEmpty) {
          final pending = _pendingRequests.removeFirst();
          pending();
        }
      } else {
        // Refresh falló: limpiar tokens y rechazar request
        await _authTokenStorage.clearAll();
        handler.reject(err);
      }

      _isRefreshing = false;
      return;
    }

    // Para 403 u otros errores, simplemente dejamos pasar
    return super.onError(err, handler);
  }

  /// Intenta renovar el token usando el refresh token.
  Future<bool> _attemptRefresh() async {
    final refreshToken = await _authTokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      // Necesitamos un Dio temporal sin este interceptor para evitar loops
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final response = await dio.post(
        ApiConstants.refresh, // Usa la constante en lugar del path estricto con '/'
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['accessToken'] as String?;
      final newRefreshToken = response.data['refreshToken'] as String?;

      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        await _authTokenStorage.saveToken(newAccessToken);
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await _authTokenStorage.saveRefreshToken(newRefreshToken);
        }
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('[AuthInterceptor] Refresh failed: $e');
      }
      return false;
    }
  }

  /// Reintenta la petición original con el nuevo token.
  Future<void> _retryRequest(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final token = await _authTokenStorage.readToken();
      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $token';

      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await dio.fetch(options);
      handler.resolve(response);
    } catch (e) {
      handler.reject(err);
    }
  }
}