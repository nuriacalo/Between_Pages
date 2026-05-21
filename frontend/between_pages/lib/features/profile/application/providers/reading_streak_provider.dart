
import 'package:between_pages/features/profile/domain/reading_streak_dto.dart';
import 'package:between_pages/features/profile/application/repositories/reading_stats_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final readingStreakProvider = FutureProvider<ReadingStreakDTO>((ref) async {
  final repo = ref.read(readingStatsRepositoryProvider);
  try {
    return await repo.getReadingStreak();
  } catch (e) {
    // En caso de error (ej. offline), devolvemos un estado por defecto.
    return ReadingStreakDTO(
      currentStreak: 0,
      weekActivity: List.filled(7, false),
      totalActiveDays: 0,
    );
  }
});
