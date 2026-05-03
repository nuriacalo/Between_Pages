// lib/providers/journal/manga_journal_provider.dart
import 'package:between_pages/models/journal/manga_journal_response_dto.dart';
import 'package:between_pages/providers/user/user_provider.dart';
import 'package:between_pages/repositories/manga_journal_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mangaJournalProvider = FutureProvider<List<MangaJournalResponseDTO>>((
  ref,
) async {
  final user = await ref.watch(userProfileProvider.future);
  final repository = ref.watch(mangaJournalRepositoryProvider);
  return await repository.getForUser(user.idUser);
});

/// Provider para buscar un journal entry específico por mangaId
final mangaJournalEntryProvider =
    FutureProvider.family<MangaJournalResponseDTO?, int>((ref, mangaId) async {
      final journals = await ref.watch(mangaJournalProvider.future);
      try {
        return journals.firstWhere((j) => j.manga?.idManga == mangaId);
      } catch (e) {
        return null;
      }
    });
