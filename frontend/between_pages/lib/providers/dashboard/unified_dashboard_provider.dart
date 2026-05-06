import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../journal/reading_stats_provider.dart';
import '../user/reading_goal_provider.dart';
import '../user/reading_streak_provider.dart';
import '../search/unified_search_provider.dart';

final unifiedDashboardProvider = FutureProvider((ref) async {
  // final stats = ref.watch(readingStatsProvider); // FIXME: readingStatsProvider is undefined
  final goal = ref.watch(currentReadingGoalProvider);
  final streak = ref.watch(readingStreakProvider);
  // Add more unified data
  return {
    // 'stats': stats.value,
    'goal': goal.value,
    'streak': streak.value,
  };
});
