import 'package:between_pages/features/profile/domain/gamification_stats_dto.dart';
import 'package:between_pages/features/profile/application/repositories/gamification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// An [AsyncNotifier] responsible for managing the user's gamification state.
/// 
/// It fetches the initial stats (current streak, annual goal, and weekly activity map)
/// from the backend and holds it in memory. It also provides methods to mutate this 
/// state optimistically, ensuring the UI remains highly responsive even on slow networks.
class GamificationNotifier extends AsyncNotifier<GamificationStatsDTO> {
  
  /// Fetches the user's gamification stats from the repository on initialization.
  @override
  Future<GamificationStatsDTO> build() async {
    return ref.watch(gamificationRepositoryProvider).getStats();
  }

  /// Updates the user's annual reading goal (target amount of books to read this year).
  /// 
  /// Employs an **optimistic UI update** pattern:
  /// 1. Immediately updates the local state so the UI reflects the change instantly.
  /// 2. Fires off the network request to save the change to the backend.
  /// 3. If the network request fails, silently reverts the state back to its original value.
  /// 
  /// @param newGoal the integer value representing the new amount of books the user wants to read.
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

/// A global provider exposing the [GamificationNotifier].
/// Widgets can watch this to reactively build UI based on the user's streak and goals.
final gamificationProvider = AsyncNotifierProvider<GamificationNotifier, GamificationStatsDTO>(() {
  return GamificationNotifier();
});
