import 'package:between_pages/api/api_client.dart';
import 'package:between_pages/screens/library/gamification_stats_dto.dart';
import 'package:between_pages/providers/auth/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GamificationRepository {
  final ApiClient _apiClient;

  GamificationRepository(this._apiClient);

  Future<GamificationStatsDTO> getStats() async {
    try {
      final response = await _apiClient.get('/gamification/stats');
      return GamificationStatsDTO.fromJson(response.data);
    } catch (e) {
      // Fallback: Si el endpoint aún no está listo en el backend, devolvemos datos vacíos
      // en lugar de romper la interfaz de usuario.
      return GamificationStatsDTO(
        annualGoal: 12,
        currentStreak: 0,
        weekActivity: List.filled(7, false),
      );
    }
  }

  Future<void> updateGoal(int year, int newGoal) async {
    try {
      await _apiClient.post('/gamification/goal', data: {
        'goalYear': year,
        'targetAmount': newGoal,
      });
    } catch (e) {
      // Fallback silencioso temporal
    }
  }
}

final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) {
  return GamificationRepository(ref.watch(apiClientProvider));
});