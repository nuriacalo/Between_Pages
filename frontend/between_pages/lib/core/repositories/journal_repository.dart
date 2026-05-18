import 'dart:convert';
import 'package:between_pages/core/api/api_client.dart';
import 'package:between_pages/features/journal/domain/book_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/fanfic_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/domain/manga_journal_response_dto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Repositorio de journal que encapsula la lógica común de CRUD.
class JournalRepository<T> {
  final ApiClient _apiClient;
  final JournalType _type;

  // Backend endpoints (JournalController)
  // POST:
  //   /api/journal/book | /api/journal/manga | /api/journal/fanfic
  // GET:
  //   /api/journal/BOOK|MANGA|FANFIC/user/{userId}
  String get _journalBase => '/journal';

  String get _saveUrl {
    switch (_type) {
      case JournalType.book:
        return '$_journalBase/book';
      case JournalType.manga:
        return '$_journalBase/manga';
      case JournalType.fanfic:
        return '$_journalBase/fanfic';
    }
  }

  String get _userUrl {
    switch (_type) {
      case JournalType.book:
        return '$_journalBase/BOOK/user';
      case JournalType.manga:
        return '$_journalBase/MANGA/user';
      case JournalType.fanfic:
        return '$_journalBase/FANFIC/user';
    }
  }


  /// Parsea un JSON individual al tipo T
  T Function(Map<String, dynamic>) parser;

  JournalRepository.book(ApiClient client)
      : _apiClient = client,
        _type = JournalType.book,
        parser = ((json) => BookJournalResponseDto.fromJson(json) as T);

  JournalRepository.manga(ApiClient client)
      : _apiClient = client,
        _type = JournalType.manga,
        parser = ((json) => MangaJournalResponseDTO.fromJson(json) as T);

  JournalRepository.fanfic(ApiClient client)
      : _apiClient = client,
        _type = JournalType.fanfic,
        parser = ((json) => FanficJournalResponseDTO.fromJson(json) as T);


  /// Obtiene todos los journals de un usuario
  Future<List<T>> getForUser(int userId) async {
    try {
      final response = await _apiClient.get('$_userUrl/$userId');
      final List<dynamic> data = response.data;
      return data.map((json) => parser(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(
        'Backend dice: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Error al procesar los datos: $e');
    }
  }

  /// Guarda un nuevo journal
  Future<Map<String, dynamic>> saveRaw(Map<String, dynamic> json) async {
    try {
      debugPrint('[JournalRepository] POST $_saveUrl');
      debugPrint('[JournalRepository] Payload: ${jsonEncode(json)}');
      final response = await _apiClient.post(_saveUrl, data: json);
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
    // El backend actual solo expone POST (no PUT/PATCH) en JournalController.
    try {
      debugPrint('[JournalRepository] POST $_saveUrl (update)');
      debugPrint('[JournalRepository] Payload: ${jsonEncode(json)}');
      final response = await _apiClient.post(_saveUrl, data: json);
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
