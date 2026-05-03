import 'package:between_pages/api/api_client.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/models/catalog/book_response_dto.dart';
import 'package:between_pages/models/catalog/manga_response_dto.dart';
import 'package:between_pages/models/catalog/fanfiction_response_dto.dart';
import 'package:between_pages/providers/auth/api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repositorio para obtener el catálogo completo de libros, mangas y fanfics.
class CatalogRepository {
  final ApiClient _apiClient;

  CatalogRepository(this._apiClient);

  Future<List<BookResponseDTO>> getAllBooks() async {
    try {
      final response = await _apiClient.get(ApiConstants.book);
      final List<dynamic> data = response.data;
      return data.map((json) => BookResponseDTO.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
        'Error al obtener libros: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<List<MangaResponseDTO>> getAllManga() async {
    try {
      final response = await _apiClient.get(ApiConstants.manga);
      final List<dynamic> data = response.data;
      return data.map((json) => MangaResponseDTO.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
        'Error al obtener mangas: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<List<FanfictionResponseDTO>> getAllFanfics() async {
    try {
      final response = await _apiClient.get(ApiConstants.fanfic);
      final List<dynamic> data = response.data;
      return data.map((json) => FanfictionResponseDTO.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
        'Error al obtener fanfics: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}',
      );
    }
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ref.watch(apiClientProvider));
});
