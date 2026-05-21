import 'package:between_pages/core/api/api_client.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/features/auth/application/providers/api_provider.dart';
import 'package:between_pages/features/profile/domain/reading_streak_dto.dart';
import 'package:between_pages/features/profile/domain/reading_goal_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repositorio para gestionar las estadísticas de lectura del usuario.
class ReadingStatsRepository {
  final ApiClient _apiClient;

  ReadingStatsRepository(this._apiClient);

  /// Obtiene el progreso de la meta anual de lectura.
  /// Devuelve un mapa con 'goal' (meta) y 'progress' (progreso).
  Future<Map<String, int>> getAnnualGoalProgress() async {
    const endpoint = '/reading-stats/annual-progress';
    final response = await _apiClient.get(endpoint);
    final data = response.data as Map<String, dynamic>;

    // El backend debería devolver algo como:
    // { "targetAmount": 30, "finishedCount": 5, "year": 2024 }
    return {
      'goal': (data['targetAmount'] ?? 0) as int,
      'progress': (data['finishedCount'] ?? 0) as int,
    };
  }

  /// Registra una actividad de lectura para el día de hoy.
  /// Esto es usado para calcular la racha de lectura.
  Future<void> recordActivity() async {
    await _apiClient.post(ApiConstants.readingStatsActivity);
  }

  /// Obtiene la racha de lectura actual y la actividad semanal.
  Future<ReadingStreakDTO> getReadingStreak() async {
    final response = await _apiClient.get(ApiConstants.readingStatsStreak);
    return ReadingStreakDTO.fromJson(response.data as Map<String, dynamic>);
  }

  /// Obtiene la meta de lectura de un año específico (o actual si es nulo).
  Future<ReadingGoalDTO?> getReadingGoal([int? year]) async {
    try {
      final queryParams = year != null ? {'year': year} : null;
      final response = await _apiClient.get(ApiConstants.readingStatsGoal, queryParameters: queryParams);
      if (response.data == null || response.data.toString().isEmpty) return null;
      return ReadingGoalDTO.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null; // Si no hay meta configurada o hay un error, devolvemos null
    }
  }

  /// Actualiza o establece la meta de lectura anual.
  Future<void> updateReadingGoal(int targetAmount) async {
    await _apiClient.post(ApiConstants.readingStatsGoal, data: {'targetAmount': targetAmount});
  }

  /// Obtiene estadísticas de lectura para un item específico (velocidad, etc.).
  /// NOTA: Requiere un endpoint en el backend, ej: /api/reading-stats/item/{itemId}
  Future<Map<String, dynamic>> getItemReadingStats(int itemId) async {
    try {
      final endpoint = '/reading-stats/item/$itemId';
      final response = await _apiClient.get(endpoint);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      // Si falla (ej: endpoint no existe aún), devolvemos un mapa vacío
      // para no romper la UI.
      return {};
    }
  }
}

final readingStatsRepositoryProvider = Provider<ReadingStatsRepository>((ref) {
  return ReadingStatsRepository(ref.watch(apiClientProvider));
});