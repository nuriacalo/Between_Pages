import 'package:between_pages/features/profile/application/providers/reading_goal_provider.dart';
import 'package:between_pages/features/profile/application/providers/reading_streak_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final unifiedDashboardProvider = FutureProvider((ref) async {
  final goal = await ref.watch(currentReadingGoalProvider.future);
  final streak = await ref.watch(readingStreakProvider.future);
  return {
    'goal': goal,
    'streak': streak,
  };
});
