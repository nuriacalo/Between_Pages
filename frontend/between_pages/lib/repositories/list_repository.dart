import 'package:between_pages/api/api_client.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/models/lists/custom_list_dto.dart';
import 'package:between_pages/providers/auth/api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListRepository {
  final ApiClient _apiClient;

  ListRepository(this._apiClient);

  Future<List<CustomListDTO>> getUserLists(int userId) async {
    try {
      final response = await _apiClient.get('${ApiConstants.listUser}$userId');
      final List<dynamic> data = response.data;
      return data.map((json) => CustomListDTO.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Error al obtener las listas: ${e.message}',
      );
    }
  }
}

final listRepositoryProvider = Provider<ListRepository>((ref) {
  return ListRepository(ref.watch(apiClientProvider));
});
