import 'package:between_pages/models/user/reading_goal_dto.dart';
import 'package:between_pages/repositories/reading_stats_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final readingGoalProvider = FutureProvider.family<ReadingGoalDTO?, int>((ref, year) async {
  final repo = ref.read(readingStatsRepositoryProvider);
  return repo.getReadingGoal();
});

final currentReadingGoalProvider = FutureProvider<ReadingGoalDTO?>((ref) async {
  final year = DateTime.now().year;
  return ref.watch(readingGoalProvider(year).future);
});

final updateReadingGoalProvider = AutoDisposeFutureProvider.family<void, int>((ref, goal) async {
  final repo = ref.read(readingStatsRepositoryProvider);
  await repo.updateReadingGoal(goal);
  ref.invalidate(currentReadingGoalProvider);
});
