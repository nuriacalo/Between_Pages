import 'package:between_pages/models/journal/book_journal_record_dto.dart';
import 'package:dio/dio.dart';

import '../api/api_client.dart';

class LibroJournalService {
  final ApiClient _api;

  LibroJournalService(this._api);

  Future<BookJournalRecordDTO> saveOrUpdateLibroJournal(
    BookJournalRecordDTO dto,
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

      return BookJournalRecordDTO.fromJson(body);
    } on DioException {
      rethrow;
    }
  }
}
