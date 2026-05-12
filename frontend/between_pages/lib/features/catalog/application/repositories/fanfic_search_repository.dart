import 'package:between_pages/core/api/api_client.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/auth/application/providers/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repositorio para buscar fanfics en el catálogo.
class FanficSearchRepository {
  final ApiClient _apiClient;

  FanficSearchRepository(this._apiClient);

  /// Busca fanfics por título o término de búsqueda.
  Future<List<FanfictionResponseDTO>> searchFanfics(
    String query, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.fanficSearch,
        queryParameters: {
          'title': query,
          'page': page,
          'size': size,
        },
      );

      final List<dynamic> data = response.data ?? [];
      return data.map((json) => FanfictionResponseDTO.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error buscando fanfics: $e');
    }
  }

  /// Importa un fanfic desde AO3 usando el Crawler backend
  Future<FanfictionResponseDTO> importFromAo3(String ao3Input) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.ao3Crawler,
        data: {'ao3Input': ao3Input}, // El body esperado por el DTO en Java
      );

      return FanfictionResponseDTO.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al importar la obra de AO3. Verifica el enlace o ID.');
    }
  }
}

final fanficSearchRepositoryProvider = Provider<FanficSearchRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FanficSearchRepository(apiClient);
});