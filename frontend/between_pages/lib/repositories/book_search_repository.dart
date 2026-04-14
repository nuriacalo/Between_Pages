import 'package:between_pages/api/api_client.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/models/catalog/book_response_dto.dart';
import 'package:between_pages/providers/auth/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookSearchRepository {
  final ApiClient _apiClient;

  BookSearchRepository(this._apiClient);

  Future<List<BookResponseDTO>> searchBooks(
    String query, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.bookSearch,
        queryParameters: {'q': query},
      );

      final List<dynamic> data = response.data ?? [];
      return data.map((json) => BookResponseDTO.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error buscando libros: $e');
    }
  }
}

final bookSearchRepositoryProvider = Provider<BookSearchRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookSearchRepository(apiClient);
});
