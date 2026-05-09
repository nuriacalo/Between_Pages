import 'package:between_pages/screens/library/gamification_stats_dto.dart';
import 'package:between_pages/repositories/gamification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GamificationNotifier extends AsyncNotifier<GamificationStatsDTO> {
  @override
  Future<GamificationStatsDTO> build() async {
    return ref.watch(gamificationRepositoryProvider).getStats();
  }

  Future<void> updateGoal(int newGoal) async {
    final previousState = state.value;
    
    // 1. Actualización optimista: Actualizamos la UI instantáneamente
    if (previousState != null) {
      state = AsyncData(GamificationStatsDTO(
        annualGoal: newGoal,
        currentStreak: previousState.currentStreak,
        weekActivity: previousState.weekActivity,
      ));
    }

    // 2. Guardamos en el backend
    try {
      final currentYear = DateTime.now().year;
      await ref.read(gamificationRepositoryProvider).updateGoal(currentYear, newGoal);
    } catch (e) {
      // Si falla la red, revertimos al estado anterior sin que el usuario note cuelgues
      if (previousState != null) state = AsyncData(previousState);
    }
  }
}

final gamificationProvider = AsyncNotifierProvider<GamificationNotifier, GamificationStatsDTO>(() {
  return GamificationNotifier();
});