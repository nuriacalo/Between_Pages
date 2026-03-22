// lib/core/api/api_client.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';

  // Guardar token
  static Future<void> guardarToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Obtener token
  static Future<String?> obtenerToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Eliminar token (logout)
  static Future<void> eliminarToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Headers con token
  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await obtenerToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // GET
  static Future<dynamic> get(String url, {bool auth = true}) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _headers(auth: auth),
      );
      return _procesarRespuesta(response);
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // POST
  static Future<dynamic> post(String url, Map<String, dynamic> body,
      {bool auth = true}) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await _headers(auth: auth),
        body: jsonEncode(body),
      );
      return _procesarRespuesta(response);
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // PUT
  static Future<dynamic> put(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: await _headers(),
        body: jsonEncode(body),
      );
      return _procesarRespuesta(response);
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // DELETE
  static Future<dynamic> delete(String url) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: await _headers(),
      );
      return _procesarRespuesta(response);
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Procesar respuesta
  static dynamic _procesarRespuesta(http.Response response) {
    if (kDebugMode) {
      print('${response.statusCode} - ${response.request?.url}');
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception(
          'Error ${response.statusCode}: ${utf8.decode(response.bodyBytes)}');
    }
  }
}