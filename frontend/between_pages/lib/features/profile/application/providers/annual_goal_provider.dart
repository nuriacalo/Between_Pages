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
    try {
      final goal = await _repo.getAnnualGoal(_userId);
      state = AsyncData(goal);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<void> setGoal(int target) async {
    state = const AsyncLoading();
    try {
      await _repo.setAnnualGoal(_userId, target);
      _fetchGoal();
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  void invalidate() {
    _fetchGoal();
  }
}

final annualGoalProvider = StateNotifierProvider<AnnualGoalNotifier, AsyncValue<AnnualGoal>>((ref) {
  // This will be replaced by the actual user ID provider
  const userId = 1; 
  return AnnualGoalNotifier(ref.watch(profileRepositoryProvider), userId);
});