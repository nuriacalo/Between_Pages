import 'package:between_pages/models/journal/book_journal_record_dto.dart';
import 'package:dio/dio.dart';

import '../api/api_client.dart';

class BookJournalService {
  final ApiClient _api;

  BookJournalService(this._api);

  Future<BookJournalRecordDTO> saveOrUpdateBookJournal(
    BookJournalRecordDTO dto,
  ) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/api/book-journal',
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
