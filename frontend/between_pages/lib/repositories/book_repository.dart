import 'package:between_pages/api/api_client.dart';
import 'package:between_pages/models/catalog/book_response_dto.dart';
import 'package:between_pages/providers/api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookRepository {
  final ApiClient _apiClient;

  BookRepository(this._apiClient);

  // Obtener la lista de todos los libros
  Future<List<BookResponseDTO>> getBooks() async {
    try {
      final response = await _apiClient.get('/libros');
      final List<dynamic> data = response.data;
      return data.map((json) => BookResponseDTO.fromJson(json)).toList();
    } on DioException catch (e) {
      // Manejar errores de la solicitud
      throw Exception('Error al obtener los libros: ${e.message}');
    }
  }
}

// Proveedor del repositorio
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository(ref.watch(apiClientProvider));
});
