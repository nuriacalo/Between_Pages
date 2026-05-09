import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/models/journal/manga_journal_record_dto.dart';
import 'package:between_pages/models/journal/manga_journal_response_dto.dart';
import 'package:between_pages/providers/auth/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'journal_repository.dart';

class MangaJournalRepository extends JournalRepository<MangaJournalResponseDTO> {
  MangaJournalRepository(super.apiClient);

  @override
  String buildUserUrl(int userId) => '${ApiConstants.mangaJournalUser}$userId';

  @override
  String get saveUrl => ApiConstants.mangaJournal;

  @override
  MangaJournalResponseDTO parseItem(Map<String, dynamic> json) =>
      MangaJournalResponseDTO.fromJson(json);

  /// Guarda o actualiza un manga en el journal (con tipo específico)
  Future<MangaJournalRecordDTO> saveOrUpdate(MangaJournalRecordDTO dto) async {
    // Usamos updateRaw porque en nuestro backend saveProgress ahora es un PUT
    final raw = await updateRaw(dto.toJson());
    return MangaJournalRecordDTO.fromJson(raw);
  }
}

final mangaJournalRepositoryProvider = Provider<MangaJournalRepository>((ref) {
  return MangaJournalRepository(ref.watch(apiClientProvider));
});
