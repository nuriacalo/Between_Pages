import 'package:between_pages/api/auth_token_storage.dart';
import 'package:dio/dio.dart';

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

    // Si existe, lo inyectamos en el header de la petición
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Si recibimos un error 401 (Unauthorized), significa que el token no es válido o ha expirado
    if (err.response?.statusCode == 401) {
      // Eliminamos el token almacenado
      await _authTokenStorage.removeToken();
    }

    return super.onError(err, handler);
  }
}
