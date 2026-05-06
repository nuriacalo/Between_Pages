import 'package:between_pages/api/api_client.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/models/catalog/book_response_dto.dart';
import 'package:between_pages/providers/auth/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repositorio para buscar libros en el catálogo.
class BookSearchRepository {
  final ApiClient _apiClient;

  BookSearchRepository(this._apiClient);

  /// Busca libros por título o término de búsqueda.
  /// [page] y [size] permiten paginar los resultados.
  Future<List<BookResponseDTO>> searchBooks(
    String query, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.bookSearch,
        queryParameters: {'q': query, 'page': page, 'size': size},
      );

      final List<dynamic> data = response.data ?? [];
      return data.map((json) => BookResponseDTO.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error buscando libros: $e');
    }
  }

  /// Obtiene los detalles de un libro específico mediante su ID de Google.
  Future<BookResponseDTO> getBookByGoogleId(String googleBooksId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.bookSearch}/$googleBooksId', // Ajusta este endpoint si tu backend usa otra ruta
      );
      return BookResponseDTO.fromJson(response.data);
    } catch (e) {
      throw Exception('Error buscando libro por ID: $e');
    }
  }
}

final bookSearchRepositoryProvider = Provider<BookSearchRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookSearchRepository(apiClient);
});
