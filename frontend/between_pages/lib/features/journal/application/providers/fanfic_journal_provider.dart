// lib/providers/journal/fanfic_journal_provider.dart
import 'package:between_pages/models/journal/fanfic_journal_response_dto.dart';
import 'package:between_pages/providers/user/user_provider.dart';
import 'package:between_pages/repositories/fanfic_journal_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fanficJournalProvider = FutureProvider<List<FanficJournalResponseDTO>>((
  ref,
) async {
  final user = await ref.watch(userProfileProvider.future);
  final repository = ref.watch(fanficJournalRepositoryProvider);
  return await repository.getForUser(user.idUser);
});

/// Provider para buscar un journal entry específico por fanficId
final fanficJournalEntryProvider =
    FutureProvider.family<FanficJournalResponseDTO?, String>((
      ref,
      fanficId,
    ) async {
      final journals = await ref.watch(fanficJournalProvider.future);
      try {
        return journals.firstWhere((j) => j.fanfic.idFanfic?.toString() == fanficId);
      } catch (e) {
        return null;
      }
    });
