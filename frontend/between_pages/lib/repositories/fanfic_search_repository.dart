import 'package:between_pages/api/api_client.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/models/catalog/fanfiction_response_dto.dart';
import 'package:between_pages/providers/auth/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FanficSearchRepository {
  final ApiClient _apiClient;

  FanficSearchRepository(this._apiClient);

  Future<List<FanfictionResponseDTO>> searchFanfics(
    String query, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.fanficSearch,
        queryParameters: {
          'q': query, // El backend espera 'q'
        },
      );

      final List<dynamic> data = response.data ?? [];
      return data.map((json) => FanfictionResponseDTO.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error buscando fanfics: $e');
    }
  }
}

final fanficSearchRepositoryProvider = Provider<FanficSearchRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FanficSearchRepository(apiClient);
});
