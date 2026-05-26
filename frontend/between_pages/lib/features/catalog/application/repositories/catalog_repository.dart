import 'package:between_pages/core/api/api_client.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/auth/application/providers/api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repositorio para obtener el catálogo de un usuario.
class CatalogRepository {
  final ApiClient _apiClient;

  CatalogRepository(this._apiClient);

  Future<List<BookResponseDTO>> getAllBooks(int userId) async {
    try {
      final response = await _apiClient.get('${ApiConstants.book}/user/$userId');
      final List<dynamic> data = response.data;
      return data.map((json) => BookResponseDTO.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
        'Error al obtener libros del usuario: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<BookResponseDTO> getBookByGoogleId(String googleBooksId) async {
    try {
      final response =
          await _apiClient.get('${ApiConstants.book}/google/$googleBooksId');
      return BookResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Error al obtener libro por Google ID: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<List<MangaResponseDTO>> getAllManga(int userId) async {
    try {
      final response = await _apiClient.get('${ApiConstants.manga}/user/$userId');
      final List<dynamic> data = response.data;
      return data.map((json) => MangaResponseDTO.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
        'Error al obtener mangas del usuario: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<List<FanfictionResponseDTO>> getAllFanfics(int userId) async {
    try {
      final response = await _apiClient.get('${ApiConstants.fanfic}/user/$userId');
      final List<dynamic> data = response.data;
      return data.map((json) => FanfictionResponseDTO.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
        'Error al obtener fanfics del usuario: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<BookResponseDTO> saveOrUpdateBook(BookResponseDTO book) async {
    try {
      final Response response;
      if (book.idBook == null || book.idBook == 0) {
        // Crear nuevo libro
        response = await _apiClient.post(ApiConstants.book, data: book.toJson());
      } else {
        // Actualizar libro existente
        response = await _apiClient.put('${ApiConstants.book}/${book.idBook}',
            data: book.toJson());
      }
      return BookResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Error al guardar el libro: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<FanfictionResponseDTO> saveOrUpdateFanfic(
      FanfictionResponseDTO fanfic) async {
    try {
      final Response response;
      if (fanfic.idFanfic == null || fanfic.idFanfic == 0) {
        response =
            await _apiClient.post(ApiConstants.fanfic, data: fanfic.toJson());
      } else {
        response = await _apiClient.put(
            '${ApiConstants.fanfic}/${fanfic.idFanfic}',
            data: fanfic.toJson());
      }
      return FanfictionResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
          'Error al guardar el fanfic: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}');
    }
  }

  Future<MangaResponseDTO> saveOrUpdateManga(MangaResponseDTO manga) async {
    try {
      final Response response;
      if (manga.idManga == 0) {
        // Crear nuevo manga
        response = await _apiClient.post(ApiConstants.manga, data: manga.toJson());
      } else {
        // Actualizar manga existente
        response = await _apiClient.put('${ApiConstants.manga}/${manga.idManga}', data: manga.toJson());
      }
      return MangaResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Error al guardar el manga: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}',
      );
    }
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ref.watch(apiClientProvider));
});
