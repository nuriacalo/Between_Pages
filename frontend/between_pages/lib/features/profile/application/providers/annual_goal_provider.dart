import 'package:between_pages/features/profile/application/providers/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:between_pages/features/profile/application/repositories/profile_repository.dart';

class AnnualGoal {
  final int target;
  final int completed;

  const AnnualGoal({this.target = 0, this.completed = 0});
}

class AnnualGoalNotifier extends StateNotifier<AsyncValue<AnnualGoal>> {
  final ProfileRepository _repo;
  final int _userId;

  AnnualGoalNotifier(this._repo, this._userId) : super(const AsyncLoading()) {
    _fetchGoal();
  }

  Future<void> _fetchGoal() async {
    if (_userId == -1) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }
    try {
      final goal = await _repo.getAnnualGoal(_userId);
      state = AsyncData(goal);
    } catch (e, s) {
      if (kDebugMode) {
        print('Error fetching annual goal: $e');
        print(s);
      }
      state = AsyncError(e, s);
    }
  }

  Future<void> setGoal(int target) async {
    state = const AsyncLoading();
    if (_userId == -1) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }
    try {
      await _repo.setAnnualGoal(_userId, target);
      _fetchGoal();
    } catch (e, s) {
      if (kDebugMode) {
        print('Error setting annual goal: $e');
        print(s);
      }
      state = AsyncError(e, s);
    }
  }

  void invalidate() {
    _fetchGoal();
  }
}

final annualGoalProvider = StateNotifierProvider<AnnualGoalNotifier, AsyncValue<AnnualGoal>>((ref) {
  final user = ref.watch(userProfileProvider);
  final userId = user.when(
    data: (user) => user.idUser,
    loading: () => -1,
    error: (error, stackTrace) {
      if (kDebugMode) {
        print('Error getting user profile for annual goal: $error');
        print(stackTrace);
      }
      return -1;
    },
  );
  if (kDebugMode) {
    print('Annual goal provider using userId: $userId');
  }
  return AnnualGoalNotifier(ref.watch(profileRepositoryProvider), userId);
});