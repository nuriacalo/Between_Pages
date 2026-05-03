import 'package:between_pages/repositories/reading_session_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final itemReadingStatsProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final repo = ref.watch(readingSessionRepositoryProvider);
  return repo.getItemStats(
    bookId: params['bookId'],
    mangaId: params['mangaId'],
    fanficId: params['fanficId'],
    remainingPages: params['remainingPages'] ?? 0,
  );
});