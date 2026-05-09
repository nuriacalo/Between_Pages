import 'dart:convert';
import 'package:between_pages/api/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Clase base para repositorios de journal que encapsula
/// la lógica común de CRUD contra endpoints REST.
abstract class JournalRepository<T> {
  final ApiClient _apiClient;

  JournalRepository(this._apiClient);

  /// Construye la URL para obtener los journals de un usuario
  String buildUserUrl(int userId);

  /// Construye la URL base para guardar/actualizar un journal
  String get saveUrl;

  /// Parsea un JSON individual al tipo T
  T parseItem(Map<String, dynamic> json);

  /// Obtiene todos los journals de un usuario
  Future<List<T>> getForUser(int userId) async {
    try {
      final response = await _apiClient.get(buildUserUrl(userId));
      final List<dynamic> data = response.data;
      return data
          .map((json) => parseItem(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        'Backend dice: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}',
      );
    }
  }

  /// Guarda un nuevo journal
  Future<Map<String, dynamic>> saveRaw(Map<String, dynamic> json) async {
    try {
      debugPrint('[JournalRepository] POST $saveUrl');
      debugPrint('[JournalRepository] Payload: ${jsonEncode(json)}');
      final response = await _apiClient.post(saveUrl, data: json);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('[JournalRepository] Error: ${e.response?.statusCode}');
      debugPrint('[JournalRepository] Response: ${e.response?.data}');
      throw Exception(
        'Error al guardar en journal: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}',
      );
    }
  }

  /// Actualiza un journal existente
  Future<Map<String, dynamic>> updateRaw(Map<String, dynamic> json) async {
    try {
      debugPrint('[JournalRepository] PUT $saveUrl');
      debugPrint('[JournalRepository] Payload: ${jsonEncode(json)}');
      final response = await _apiClient.put(saveUrl, data: json);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('[JournalRepository] Error: ${e.response?.statusCode}');
      debugPrint('[JournalRepository] Response: ${e.response?.data}');
      throw Exception(
        'Error al actualizar en journal: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}',
      );
    }
  }
}
