import 'package:between_pages/core/api/api_client.dart';
import 'package:between_pages/features/auth/application/providers/api_provider.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repositorio para buscar libros en fuentes externas (Google Books) usando el backend.
/// Endpoint: GET /api/external/book/search?q={query}
class ExternalBookRepository {
  final ApiClient _apiClient;

  ExternalBookRepository(this._apiClient);

  Future<List<BookResponseDTO>> searchBooks(
    String query, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/external/book/search',

        queryParameters: {
          'q': query,
          // tu backend no recibe paginación aquí, pero dejamos placeholders
          // por si luego lo soporta.
          if (page != 0) 'page': page,
          if (size != 20) 'size': size,
        },
      );

      final data = _extractList(response.data);
      return data
          .whereType<Map<String, dynamic>>()
          .map(BookResponseDTO.fromJson)
          .toList();
    } catch (e) {
      throw Exception('Error buscando libros en Google Books: $e');
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
}

final externalBookRepositoryProvider = Provider<ExternalBookRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ExternalBookRepository(apiClient);
});
