import 'package:between_pages/models/user/reading_goal_dto.dart';
import 'package:between_pages/repositories/reading_stats_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para la meta de lectura anual del usuario
final readingGoalProvider = FutureProvider<ReadingGoalDTO>((ref) async {
  final repository = ref.watch(readingStatsRepositoryProvider);
  return await repository.getReadingGoal();
});

/// Provider para la meta actual (valor mutable para edición)
final readingGoalValueProvider = StateProvider<int>((ref) => 12);
