import 'package:between_pages/core/api/api_client.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/features/auth/application/providers/api_provider.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

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

      final data = _extractList(response.data);
      return data
          .whereType<Map<String, dynamic>>()
          .map(BookResponseDTO.fromJson)
          .toList();
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

  /// Guarda un libro nuevo o actualiza uno existente.
  /// NOTA: Requiere que `BookResponseDTO` tenga un método `toJson()`.
  Future<BookResponseDTO> saveOrUpdateBook(BookResponseDTO book) async {
    try {
      final data = book.toJson();
      Response response;

      if (book.idBook! > 0) {
        // Actualiza un libro existente
        response = await _apiClient.put(
          '${ApiConstants.book}/${book.idBook}',
          data: data,
        );
      } else {
        // Crea un libro nuevo
        response = await _apiClient.post(ApiConstants.book, data: data);
      }
      return BookResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error guardando libro');
    } catch (e) {
      throw Exception('Error inesperado guardando el libro: $e');
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

final bookSearchRepositoryProvider = Provider<BookSearchRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookSearchRepository(apiClient);
});
