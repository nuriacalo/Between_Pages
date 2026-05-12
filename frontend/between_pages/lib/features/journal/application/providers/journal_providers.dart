import 'package:between_pages/core/repositories/journal_repository.dart';
import 'package:between_pages/features/auth/application/providers/api_provider.dart';
import 'package:between_pages/features/journal/domain/base_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/book_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/fanfic_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/domain/manga_journal_response_dto.dart';
import 'package:between_pages/features/profile/application/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookJournalRepositoryProvider = Provider<JournalRepository<BookJournalResponseDto>>((ref) {
  return JournalRepository.book(ref.watch(apiClientProvider));
});

final mangaJournalRepositoryProvider = Provider<JournalRepository<MangaJournalResponseDTO>>((ref) {
  return JournalRepository.manga(ref.watch(apiClientProvider));
});

final fanficJournalRepositoryProvider = Provider<JournalRepository<FanficJournalResponseDTO>>((ref) {
  return JournalRepository.fanfic(ref.watch(apiClientProvider));
});

final journalProvider = FutureProvider.family<List<BaseJournalResponseDTO>, JournalType>((ref, type) async {
  final user = await ref.watch(userProfileProvider.future);
  switch (type) {
    case JournalType.book:
      final repository = ref.watch(bookJournalRepositoryProvider);
      return await repository.getForUser(user.idUser);
    case JournalType.manga:
      final repository = ref.watch(mangaJournalRepositoryProvider);
      return await repository.getForUser(user.idUser);
    case JournalType.fanfic:
      final repository = ref.watch(fanficJournalRepositoryProvider);
      return await repository.getForUser(user.idUser);
  }
});

final journalEntryProvider = Provider.family<BaseJournalResponseDTO?, (JournalType, int)>((ref, params) {
  final type = params.$1;
  final itemId = params.$2;
  final journalList = ref.watch(journalProvider(type));

  return journalList.when(
    data: (journals) {
      try {
        return journals.firstWhere((j) {
          if (j is BookJournalResponseDto) return j.book.idBook == itemId;
          if (j is MangaJournalResponseDTO) return j.manga?.idManga == itemId;
          if (j is FanficJournalResponseDTO) return j.fanfic.idFanfic == itemId;
          return false;
        });
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, stack) => null,
  );
});
