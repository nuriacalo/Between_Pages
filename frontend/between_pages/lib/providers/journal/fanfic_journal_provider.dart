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
  return await repository.getFanficsForUser(user.idUser);
});
