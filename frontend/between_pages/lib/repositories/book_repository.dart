import 'package:between_pages/api/api_client.dart';
import 'package:between_pages/models/catalog/book_response_dto.dart';
import 'package:between_pages/providers/api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:between_pages/core/constants/api_constants.dart';

class BookRepository {
  final ApiClient _apiClient;

  BookRepository(this._apiClient);

  // Obtener los libros que el usuario tiene en su Journal
  Future<List<BookResponseDTO>> getUserBooks(int userId) async {
    try {
      // Llamamos al endpoint del journal pasando el ID del usuario
      final response = await _apiClient.get('${ApiConstants.libroJournalUser}$userId');
      final List<dynamic> data = response.data;
      // De cada registro del journal, extraemos únicamente la información del 'libro'
      return data.map((json) => BookResponseDTO.fromJson(json['libro'])).toList();
    } on DioException catch (e) {
      // Imprimimos el error exacto que nos devuelve Spring Boot
      throw Exception('Backend dice: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}');
    }
  }
}

// Proveedor del repositorio
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository(ref.watch(apiClientProvider));
});
