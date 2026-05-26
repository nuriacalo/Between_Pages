import 'package:between_pages/core/api/api_client.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/features/auth/application/providers/api_provider.dart';
import 'package:between_pages/features/profile/domain/reading_streak_dto.dart';
import 'package:between_pages/features/profile/domain/reading_goal_dto.dart';
import 'package:between_pages/features/profile/domain/gamification_stats_dto.dart';
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
    // Enviamos la fecha local en formato YYYY-MM-DD para evitar desajustes de 
    // zona horaria entre el móvil (frontend) y el servidor (backend).
    final localDate = DateTime.now().toLocal().toIso8601String().split('T').first;
    await _apiClient.post(ApiConstants.readingStatsActivity, data: {
      'localDate': localDate,
    });
  }

  /// Obtiene la racha de lectura actual y la actividad semanal.
  Future<ReadingStreakDTO> getReadingStreak() async {
    final localDate = DateTime.now().toLocal().toIso8601String().split('T').first;
    final response = await _apiClient.get('${ApiConstants.readingStatsStreak}?localDate=$localDate');
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
  Future<void> updateReadingGoal(int targetAmount, [int? year]) async {
    final data = <String, dynamic>{'targetAmount': targetAmount};
    if (year != null) {
      data['year'] = year;
    }
    await _apiClient.post(ApiConstants.readingStatsGoal, data: data);
  }

  /// Obtiene estadísticas de lectura para un item específico (velocidad, etc.).
  /// NOTA: Requiere un endpoint en el backend, ej: /api/reading-stats/item/{itemId}
  Future<Map<String, dynamic>> getItemReadingStats(int itemId, String itemType) async {
    try {
      final endpoint = '/reading-stats/item/$itemId?type=$itemType';
      final response = await _apiClient.get(endpoint);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      // Si falla (ej: endpoint no existe aún), devolvemos un mapa vacío
      // para no romper la UI.
      return {};
    }
  }

  /// Obtiene las estadísticas combinadas (Racha y Meta).
  /// Mantenido por retrocompatibilidad temporal con GamificationStatsDTO.
  Future<GamificationStatsDTO> getGamificationStats() async {
    int annualGoal = 12;
    int currentStreak = 0;
    List<bool> weekActivity = List.filled(7, false);

    // Intentamos cargar la meta actual
    try {
      final goal = await getReadingGoal();
      if (goal != null) annualGoal = goal.targetAmount;
    } catch (_) {}

    // Intentamos cargar la racha de lectura
    try {
      final streak = await getReadingStreak();
      currentStreak = streak.currentStreak;
      weekActivity = streak.weekActivity;
    } catch (_) {}

    return GamificationStatsDTO(
      annualGoal: annualGoal,
      currentStreak: currentStreak,
      weekActivity: weekActivity,
    );
  }
}

final readingStatsRepositoryProvider = Provider<ReadingStatsRepository>((ref) {
  return ReadingStatsRepository(ref.watch(apiClientProvider));
});