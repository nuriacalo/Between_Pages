import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/models/journal/reading_session_record_dto.dart';
import 'package:between_pages/providers/auth/api_provider.dart';
import 'package:between_pages/api/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repositorio para gestionar sesiones de lectura y estadísticas
/// de velocidad de lectura.
class ReadingSessionRepository {
  final ApiClient _apiClient;

  ReadingSessionRepository(this._apiClient);

  Future<void> saveSession(ReadingSessionRecordDTO dto) async {
    try {
      await _apiClient.post(ApiConstants.readingSessions, data: dto.toJson());
    } catch (e) {
      debugPrint('Error al guardar la sesión de lectura: $e');
      throw Exception('Error al guardar la sesión de lectura: $e');
    }
  }

  Future<Map<String, dynamic>> getItemStats({
    int? bookId,
    int? mangaId,
    int? fanficId,
    required int remainingPages,
  }) async {
    try {
      final queryParams = <String, dynamic>{'remainingPages': remainingPages};
      if (bookId != null) queryParams['bookId'] = bookId;
      if (mangaId != null) queryParams['mangaId'] = mangaId;
      if (fanficId != null) queryParams['fanficId'] = fanficId;

      final response = await _apiClient.get(
        '${ApiConstants.readingSessions}/stats',
        queryParameters: queryParams,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      // Lanzamos la excepción para evitar que el UI interprete un error 404 
      // como una petición exitosa, lo que estaba causando el bucle infinito.
      throw Exception('Error al obtener las estadísticas de lectura: $e');
    }
  }
}

final readingSessionRepositoryProvider = Provider<ReadingSessionRepository>((
  ref,
) {
  return ReadingSessionRepository(ref.watch(apiClientProvider));
});
