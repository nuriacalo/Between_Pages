import 'package:between_pages/models/user/reading_streak_dto.dart';
import 'package:between_pages/repositories/reading_stats_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para la racha de lectura y actividad semanal del usuario
final readingStreakProvider = FutureProvider<ReadingStreakDTO>((ref) async {
  final repository = ref.watch(readingStatsRepositoryProvider);
  return await repository.getReadingStreak();
});
