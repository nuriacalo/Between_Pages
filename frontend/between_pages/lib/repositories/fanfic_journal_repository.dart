import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/models/journal/fanfic_journal_record_dto.dart';
import 'package:between_pages/models/journal/fanfic_journal_response_dto.dart';
import 'package:between_pages/providers/auth/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'journal_repository.dart';

class FanficJournalRepository extends JournalRepository<FanficJournalResponseDTO> {
  FanficJournalRepository(super.apiClient);

  @override
  String buildUserUrl(int userId) => '${ApiConstants.fanficJournalUser}$userId';

  @override
  String get saveUrl => ApiConstants.fanficJournal;

  @override
  FanficJournalResponseDTO parseItem(Map<String, dynamic> json) =>
      FanficJournalResponseDTO.fromJson(json);

  /// Guarda o actualiza un fanfic en el journal (con tipo específico)
  Future<FanficJournalRecordDTO> saveOrUpdate(FanficJournalRecordDTO dto) async {
    final raw = await saveRaw(dto.toJson());
    return FanficJournalRecordDTO.fromJson(raw);
  }
}

final fanficJournalRepositoryProvider = Provider<FanficJournalRepository>((ref) {
  return FanficJournalRepository(ref.watch(apiClientProvider));
});

