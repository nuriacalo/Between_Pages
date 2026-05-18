import 'package:between_pages/core/api/api_client.dart';
import 'package:between_pages/features/auth/application/providers/api_provider.dart';
import 'package:between_pages/features/profile/application/providers/annual_goal_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  Future<AnnualGoal> getAnnualGoal(int userId) async {
    // Using the endpoint from ProfileController
    final response = await _apiClient.get('/profile/$userId/goal');
    return AnnualGoal(
      target: response.data['target'] ?? 0,
      completed: response.data['completed'] ?? 0,
    );
  }

  Future<void> setAnnualGoal(int userId, int target) async {
    // Using the endpoint from ProfileController
    await _apiClient.post(
      '/profile/$userId/goal',
      data: {'target': target},
    );
  }
}

final profileRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient);
});