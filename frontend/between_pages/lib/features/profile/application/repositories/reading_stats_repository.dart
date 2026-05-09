// lib/repositories/reading_stats_repository.dart
import 'package:between_pages/api/api_client.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/models/user/reading_goal_dto.dart';
import 'package:between_pages/models/user/reading_streak_dto.dart';
import 'package:between_pages/providers/auth/api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadingStatsRepository {
  final ApiClient _apiClient;

  ReadingStatsRepository(this._apiClient);

  /// Obtiene la meta de lectura anual del usuario
  Future<ReadingGoalDTO> getReadingGoal() async {
    try {
      final response = await _apiClient.get(ApiConstants.readingStatsGoal);
      return ReadingGoalDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Error al obtener meta: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}',
      );
    }
  }

  /// Actualiza la meta de lectura anual
  Future<ReadingGoalDTO> updateReadingGoal(int targetAmount) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.readingStatsGoal,
        queryParameters: {'targetAmount': targetAmount},
      );
      return ReadingGoalDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Error al actualizar meta: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}',
      );
    }
  }

  /// Obtiene la racha de lectura y actividad semanal
  Future<ReadingStreakDTO> getReadingStreak() async {
    try {
      final response = await _apiClient.get(ApiConstants.readingStatsStreak);
      return ReadingStreakDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Error al obtener racha: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}',
      );
    }
  }

  /// Registra actividad de lectura para hoy
  Future<void> recordActivity() async {
    try {
      await _apiClient.post(ApiConstants.readingStatsActivity);
    } on DioException catch (e) {
      throw Exception(
        'Error al registrar actividad: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}',
      );
    }
  }
}

final readingStatsRepositoryProvider = Provider<ReadingStatsRepository>((ref) {
  return ReadingStatsRepository(ref.watch(apiClientProvider));
});
