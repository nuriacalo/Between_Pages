import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/models/journal/book_journal_record_dto.dart';
import 'package:between_pages/models/journal/book_journal_response_dto.dart';
import 'package:between_pages/providers/auth/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'journal_repository.dart';

class BookJournalRepository extends JournalRepository<BookJournalResponseDto> {
  BookJournalRepository(super.apiClient);

  @override
  String buildUserUrl(int userId) => '${ApiConstants.bookJournalUser}$userId';

  @override
  String get saveUrl => ApiConstants.bookJournal;

  @override
  BookJournalResponseDto parseItem(Map<String, dynamic> json) =>
      BookJournalResponseDto.fromJson(json);

  /// Guarda o actualiza un libro en el journal (con tipo específico)
  Future<BookJournalRecordDTO> saveOrUpdate(BookJournalRecordDTO dto) async {
    // Usamos updateRaw porque en nuestro backend saveProgress ahora es un PUT
    final raw = await updateRaw(dto.toJson());
    return BookJournalRecordDTO.fromJson(raw);
  }
}

final bookJournalRepositoryProvider = Provider<BookJournalRepository>((ref) {
  return BookJournalRepository(ref.watch(apiClientProvider));
});
