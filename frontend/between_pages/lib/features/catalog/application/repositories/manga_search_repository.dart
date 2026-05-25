import 'package:between_pages/core/api/api_client.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/auth/application/providers/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repositorio para buscar mangas en el catálogo.
class MangaSearchRepository {
  final ApiClient _apiClient;

  MangaSearchRepository(this._apiClient);

  /// Obtiene todos los mangas del catálogo.
  Future<List<MangaResponseDTO>> getAllMangas() async {
    try {
      final response = await _apiClient.get(ApiConstants.manga);
      final List<dynamic> data = response.data;
      return data.map((json) => MangaResponseDTO.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error obteniendo mangas: $e');
    }
  }

  /// Busca mangas por título o término de búsqueda.
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
          'page': page,
          'size': size,
        },
      );

      final List<dynamic> data = response.data ?? [];
      return data.map((json) => MangaResponseDTO.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error buscando manga: $e');
    }
  }

  /// Busca mangas en una fuente externa (ej. Jikan API a través de nuestro backend).
  Future<List<MangaResponseDTO>> searchExternalManga(String query) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.externalMangaSearch,
        queryParameters: {'q': query, 'page': 1, 'limit': 20},
      );

      final data = _extractList(response.data);
      return data
          .whereType<Map<String, dynamic>>()
          .map(MangaResponseDTO.fromJson)
          .toList();
    } catch (e) {
      throw Exception('Error buscando mangas externos: $e');
    }
  }

  List<dynamic> _extractList(dynamic payload) {
    if (payload is List) return payload;
    if (payload is Map<String, dynamic>) {
      final nested = payload['content'] ?? payload['items'] ?? payload['results'] ?? payload['data'];
      if (nested is List) return nested;
    }
    return const [];
  }

  /// Guarda o actualiza un Manga en la base de datos local
  Future<MangaResponseDTO> saveOrUpdateManga(MangaResponseDTO manga) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.manga, 
        data: manga.toJson(),
      );
      return MangaResponseDTO.fromJson(response.data);
    } catch (e) {
      throw Exception('Error guardando o actualizando manga: $e');
    }
  }
}

final mangaSearchRepositoryProvider = Provider<MangaSearchRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MangaSearchRepository(apiClient);
});
