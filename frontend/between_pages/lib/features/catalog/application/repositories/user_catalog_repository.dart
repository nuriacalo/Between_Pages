import 'package:between_pages/core/api/api_client.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/features/auth/application/providers/api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserCatalogRepository {
  final ApiClient _apiClient;

  UserCatalogRepository(this._apiClient);

  Future<void> addToCatalog({
    required int userId,
    required String itemType,
    required String status,
    int? bookId,
    int? mangaId,
    int? fanficId,
  }) async {
    try {
      await _apiClient.post(
        ApiConstants.userCatalog,
        data: {
          'userId': userId,
          'itemType': itemType,
          'status': status,
          'bookId': bookId,
          'mangaId': mangaId,
          'fanficId': fanficId,
        },
      );
    } on DioException catch (e) {
      // Si el error es un 409 (Conflict) o similar, puede que el backend
      // ya lo haya gestionado como un "ya existe". Podemos ignorarlo o loggearlo.
      if (e.response?.statusCode == 409 || e.response?.statusCode == 200) {
        // Item ya en el catálogo, no es un error fatal.
        return;
      }
      throw Exception(
        'Error al añadir al catálogo: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}',
      );
    }
  }
}

final userCatalogRepositoryProvider = Provider<UserCatalogRepository>((ref) {
  return UserCatalogRepository(ref.watch(apiClientProvider));
});
