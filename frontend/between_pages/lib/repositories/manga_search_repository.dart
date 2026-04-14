import 'package:between_pages/api/api_client.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/models/catalog/manga_response_dto.dart';
import 'package:between_pages/providers/auth/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MangaSearchRepository {
  final ApiClient _apiClient;

  MangaSearchRepository(this._apiClient);

  Future<List<MangaResponseDTO>> searchManga(
    String query, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.mangaSearch,
        queryParameters: {
          'q': query, // El backend espera 'q'
        },
      );

      final List<dynamic> data = response.data ?? [];
      return data.map((json) => MangaResponseDTO.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error buscando manga: $e');
    }
  }
}

final mangaSearchRepositoryProvider = Provider<MangaSearchRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MangaSearchRepository(apiClient);
});
