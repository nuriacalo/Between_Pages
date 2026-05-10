import 'package:between_pages/features/lists/application/repositories/reading_list_repository.dart';
import 'package:between_pages/features/lists/domain/list_response_dto.dart';
import 'package:between_pages/features/profile/application/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Proveedor consolidado que obtiene las listas de lectura del usuario.
/// Utiliza ReadingListRepository como repositorio único.
final listProvider = FutureProvider<List<ListResponseDTO>>((ref) async {
  // Obtener usuario actual para extraer su ID
  final user = await ref.watch(userProfileProvider.future);
  // Obtener listas del usuario usando el repositorio consolidado
  return ref.watch(readingListRepositoryProvider).getUserLists(user.idUser);
});
