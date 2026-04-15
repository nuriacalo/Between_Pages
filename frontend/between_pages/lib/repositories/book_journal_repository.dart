// lib/repositories/book_journal_repository.dart
import 'package:between_pages/api/api_client.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/models/journal/book_journal_record_dto.dart';
import 'package:between_pages/models/journal/book_journal_response_dto.dart';
import 'package:between_pages/providers/auth/api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookJournalRepository {
  final ApiClient _apiClient;
  BookJournalRepository(this._apiClient);

  Future<List<BookJournalResponseDto>> getBooksForUser(int userId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.bookJournalUser}$userId',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => BookJournalResponseDto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
        'Backend dice: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}',
      );
    }
  }

  /// Guarda o actualiza un libro en el journal
  Future<BookJournalRecordDTO> saveOrUpdate(BookJournalRecordDTO dto) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.bookJournal,
        data: dto.toJson(),
      );
      return BookJournalRecordDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Error al guardar en journal: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}',
      );
    }
  }
}

final bookJournalRepositoryProvider = Provider<BookJournalRepository>((ref) {
  return BookJournalRepository(ref.watch(apiClientProvider));
});
