// lib/providers/book_journal_provider.dart
import 'package:between_pages/models/journal/book_journal_response_dto.dart';
import 'package:between_pages/providers/user/user_provider.dart';
import 'package:between_pages/repositories/book_journal_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookJournalProvider = FutureProvider<List<BookJournalResponseDto>>((
  ref,
) async {
  final user = await ref.watch(userProfileProvider.future);
  final repository = ref.watch(bookJournalRepositoryProvider);
  return await repository.getBooksForUser(user.idUser);
});
