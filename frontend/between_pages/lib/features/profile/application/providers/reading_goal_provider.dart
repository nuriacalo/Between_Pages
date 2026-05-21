import 'package:between_pages/features/profile/domain/reading_goal_dto.dart';
import 'package:between_pages/features/profile/application/repositories/reading_stats_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final annualGoalProgressProvider = FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.watch(readingStatsRepositoryProvider);
  return repo.getAnnualGoalProgress();
});

final readingGoalProvider = FutureProvider.family<ReadingGoalDTO?, int>((ref, year) async {
  final repo = ref.read(readingStatsRepositoryProvider);
  return repo.getReadingGoal(year);
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
