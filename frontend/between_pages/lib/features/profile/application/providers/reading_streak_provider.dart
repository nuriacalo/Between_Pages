import 'package:between_pages/features/profile/domain/reading_streak_dto.dart';
import 'package:between_pages/features/profile/application/repositories/reading_stats_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final readingStreakProvider = FutureProvider<ReadingStreakDTO>((ref) async {
  final repo = ref.read(readingStatsRepositoryProvider);
  return repo.getReadingStreak();
});

