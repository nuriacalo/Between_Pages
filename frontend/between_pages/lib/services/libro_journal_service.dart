import 'package:between_pages/models/journal/libro_journal_registro_dto.dart';
import 'package:between_pages/models/journal/libro_journal_respuesta_dto.dart';
import 'package:dio/dio.dart';

import '../api/api_client.dart';

class LibroJournalService {
  final ApiClient _api;

  LibroJournalService(this._api);

  Future<LibroJournalRespuestaDTO> saveOrUpdateLibroJournal(
    LibroJournalRegistroDTO dto,
  ) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/api/libro-journal',
        data: dto.toJson(),
      );

      final body = response.data;
      if (body == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Respuesta vacía del servidor',
        );
      }

      return LibroJournalRespuestaDTO.fromJson(body);
    } on DioException {
      rethrow;
    }
  }
}
