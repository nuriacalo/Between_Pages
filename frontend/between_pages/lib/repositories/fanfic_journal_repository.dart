// lib/repositories/fanfic_journal_repository.dart
import 'package:between_pages/api/api_client.dart';
import 'package:between_pages/models/journal/fanfic_journal_response_dto.dart';
import 'package:between_pages/providers/auth/api_provider.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FanficJournalRepository {
  final ApiClient _apiClient;
  FanficJournalRepository(this._apiClient);

  Future<List<FanficJournalResponseDTO>> getFanficsForUser(int userId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.fanficJournalUser}$userId',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => FanficJournalResponseDTO.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
        'Backend dice: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}',
      );
    }
  }
}

final fanficJournalRepositoryProvider = Provider<FanficJournalRepository>((ref) {
  return FanficJournalRepository(ref.watch(apiClientProvider));
});
