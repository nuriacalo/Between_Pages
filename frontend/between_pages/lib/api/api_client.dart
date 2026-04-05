import 'package:dio/dio.dart';

import 'auth_interceptor.dart';
import 'auth_token_storage.dart';

class ApiClient {
  final Dio _dio;

  ApiClient._(this._dio);

  factory ApiClient({
    required String baseUrl,
    required AuthTokenStorage tokenStorage,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Usamos el interceptor dedicado que maneja los errores 401
    dio.interceptors.add(AuthInterceptor(tokenStorage));

    return ApiClient._(dio);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      options: options,
    );
  }

  Future<Response<T>> delete_<T>(
    String path, {
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      options: options,
    );
  }
}
