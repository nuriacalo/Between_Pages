import 'package:between_pages/core/api/api_client.dart';
import 'package:between_pages/features/auth/application/providers/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repositorio para gestionar las estadísticas de lectura del usuario.
class ReadingStatsRepository {
  final ApiClient _apiClient;

  ReadingStatsRepository(this._apiClient);

  /// Obtiene el progreso de la meta anual de lectura.
  /// Devuelve un mapa con 'goal' (meta) y 'progress' (progreso).
  Future<Map<String, int>> getAnnualGoalProgress() async {
    // TODO: Mover la ruta a ApiConstants.dart
    const endpoint = '/api/reading-stats/annual-progress';
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
    // TODO: Mover la ruta a ApiConstants.dart
    await _apiClient.post('/api/reading-stats/activity');
  }
}

final readingStatsRepositoryProvider = Provider<ReadingStatsRepository>((ref) {
  return ReadingStatsRepository(ref.watch(apiClientProvider));
});