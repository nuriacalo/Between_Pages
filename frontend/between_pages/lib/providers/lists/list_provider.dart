import 'package:between_pages/models/lists/custom_list_dto.dart';
import 'package:between_pages/providers/user/user_provider.dart';
import 'package:between_pages/repositories/list_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final listProvider = FutureProvider<List<CustomListDTO>>((ref) async {
  // 1. Obtenemos el usuario actual para extraer su ID
  final user = await ref.watch(userProfileProvider.future);
  // 2. Pedimos las listas de este usuario
  return ref.watch(listRepositoryProvider).getUserLists(user.idUser);
});
