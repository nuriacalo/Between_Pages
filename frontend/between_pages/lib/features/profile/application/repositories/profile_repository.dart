import 'package:between_pages/features/profile/application/providers/annual_goal_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<AnnualGoal> getAnnualGoal(int userId) async {
    final response = await _dio.get('/profile/$userId/goal');
    return AnnualGoal(
      target: response.data['target'] ?? 0,
      completed: response.data['completed'] ?? 0,
    );
  }

  Future<void> setAnnualGoal(int userId, int target) async {
    await _dio.post('/profile/$userId/goal', data: {'target': target});
  }
}

final profileRepositoryProvider = Provider((ref) {
  // This will be replaced by the actual Dio provider
  return ProfileRepository(Dio());
});