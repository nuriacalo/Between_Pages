import 'package:between_pages/core/repositories/journal_repository.dart';
import 'package:between_pages/features/auth/application/providers/api_provider.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/domain/responses/base_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/book_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/fanfic_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/manga_journal_response_dto.dart';
import 'package:between_pages/features/profile/application/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides a specialized [JournalRepository] for interacting with the Books API.
final bookJournalRepositoryProvider = Provider<JournalRepository<BookJournalResponseDto>>((ref) {
  return JournalRepository.book(ref.watch(apiClientProvider));
});

/// Provides a specialized [JournalRepository] for interacting with the Manga API.
final mangaJournalRepositoryProvider = Provider<JournalRepository<MangaJournalResponseDTO>>((ref) {
  return JournalRepository.manga(ref.watch(apiClientProvider));
});

/// Provides a specialized [JournalRepository] for interacting with the Fanfiction API.
final fanficJournalRepositoryProvider = Provider<JournalRepository<FanficJournalResponseDTO>>((ref) {
  return JournalRepository.fanfic(ref.watch(apiClientProvider));
});

/// A highly reactive [FutureProvider] that fetches all journal entries for the
/// authenticated user sequentially to avoid overwhelming the server.
final allJournalsProvider = FutureProvider<Map<JournalType, List<BaseJournalResponseDTO>>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  final bookRepo = ref.watch(bookJournalRepositoryProvider);
  final mangaRepo = ref.watch(mangaJournalRepositoryProvider);
  final fanficRepo = ref.watch(fanficJournalRepositoryProvider);

  // Fetch sequentially to avoid timeouts
  final books = await bookRepo.getForUser(user.idUser);
  final mangas = await mangaRepo.getForUser(user.idUser);
  final fanfics = await fanficRepo.getForUser(user.idUser);

  return {
    JournalType.book: books,
    JournalType.manga: mangas,
    JournalType.fanfic: fanfics,
  };
});


/// A synchronous [Provider.family] that filters the results from [allJournalsProvider].
final journalProvider = Provider.family<AsyncValue<List<BaseJournalResponseDTO>>, JournalType>((ref, type) {
  final allJournals = ref.watch(allJournalsProvider);

  return allJournals.when(
    data: (journals) => AsyncValue.data(journals[type] ?? []),
    loading: () => const AsyncValue.loading(),
    error: AsyncValue.error,
  );
});


/// A synchronous [Provider.family] that plucks a specific journal entry out of the cached
/// [journalProvider] list.
/// 
/// It accepts a tuple `(JournalType, int itemId)` and returns the matching journal entry
/// if it exists. Because it watches the `journalProvider`, this provider will automatically 
/// rebuild any UI widget listening to it if the underlying list changes.
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