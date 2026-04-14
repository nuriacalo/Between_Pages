import 'package:between_pages/api/api_client.dart';
import 'package:between_pages/models/catalog/manga_response_dto.dart';
import 'package:between_pages/providers/auth/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repositorio para búsqueda de manga en fuentes externas.
/// El frontend habla con nuestro backend, que luego consulta APIs externas.
///
/// Fuentes soportadas:
/// - MyAnimeList (vía Jikan API)
///
/// Esto unifica la arquitectura: todas las APIs externas pasan por el backend.
class ExternalMangaRepository {
  final ApiClient _apiClient;

  ExternalMangaRepository(this._apiClient);

  /// Busca manga por título en fuentes externas (MyAnimeList/Jikan)
  /// Endpoint: GET /api/external/manga/search
  Future<List<MangaResponseDTO>> searchManga(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/external/manga/search',
        queryParameters: {'query': query, 'page': page, 'limit': limit},
      );

      final List<dynamic> data = response.data ?? [];
      return data.map((json) => MangaResponseDTO.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error buscando manga externo: $e');
    }
  }

  /// Obtiene detalles de un manga específico de MyAnimeList
  /// Endpoint: GET /api/external/manga/{malId}
  Future<MangaResponseDTO?> getMangaById(int malId) async {
    try {
      final response = await _apiClient.get('/external/manga/$malId');
      return MangaResponseDTO.fromJson(response.data);
    } catch (e) {
      throw Exception('Error obteniendo manga externo: $e');
    }
  }
}

/// Provider para el repositorio de manga externo
final externalMangaRepositoryProvider = Provider<ExternalMangaRepository>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return ExternalMangaRepository(apiClient);
});
