import 'package:between_pages/core/api/api_client.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:between_pages/features/auth/application/providers/api_provider.dart';
import 'package:between_pages/features/lists/domain/list_response_dto.dart';
import 'package:between_pages/features/lists/domain/reading_list_request_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repositorio para gestionar las colecciones personalizadas (Reading Lists)
/// mediante peticiones HTTP al backend.
class ReadingListRepository {
  final ApiClient _apiClient;

  ReadingListRepository(this._apiClient);

  /// Obtiene todas las listas de lectura pertenecientes a un [userId].
  Future<List<ListResponseDTO>> getUserLists(int userId) async {
    final response = await _apiClient.get('${ApiConstants.listUser}$userId');
    final list = response.data as List;
    return list.map((json) => ListResponseDTO.fromJson(json)).toList();
  }

  /// Crea una nueva colección personalizada para el usuario indicado.
  Future<ListResponseDTO> createList(
    int userId,
    ReadingListRequestDTO request,
  ) async {
    final response = await _apiClient.post(
      '${ApiConstants.listUser}$userId',
      data: request.toJson(),
    );
    return ListResponseDTO.fromJson(response.data);
  }

  /// Elimina de forma permanente una lista dado su [listId].
  Future<void> deleteList(int listId) async {
    await _apiClient.delete('${ApiConstants.listDelete}$listId');
  }
}

/// Provider de Riverpod para inyectar el [ReadingListRepository] globalmente.
final readingListRepositoryProvider = Provider<ReadingListRepository>((ref) {
  return ReadingListRepository(ref.watch(apiClientProvider));
});
