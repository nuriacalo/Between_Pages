import 'package:between_pages/api/api_client.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/models/journal/reading_session_record_dto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repositorio para gestionar sesiones de lectura y estadísticas
/// de velocidad de lectura.
class ReadingSessionRepository {
  final Dio _dio;

  ReadingSessionRepository(this._dio);

  Future<void> saveSession(ReadingSessionRecordDTO dto) async {
    try {
      await _dio.post(ApiConstants.readingSessions, data: dto.toJson());
    } catch (e) {
      // No relanzamos el error para no interrumpir al usuario,
      // pero lo dejamos registrado por si hay que depurar.
      print('Error al guardar la sesión de lectura: $e');
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

      final response = await _dio.get(
        '${ApiConstants.readingSessions}/stats',
        queryParameters: queryParams,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      // Fallback silencioso si no hay conexión o da error
      return {'speedPagesPerHour': 0.0, 'estimatedTimeRemainingSeconds': 0};
    }
  }
}

final readingSessionRepositoryProvider = Provider<ReadingSessionRepository>((
  ref,
) {
  return ReadingSessionRepository(ref.watch(apiClientProvider));
});
