import 'package:between_pages/models/lists/list_response_dto.dart';
import 'package:between_pages/providers/user/user_provider.dart';
import 'package:between_pages/repositories/reading_list_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider que obtiene las listas de lectura del usuario actual.
final userReadingListsProvider = FutureProvider<List<ListResponseDTO>>(
  (ref) async {
    final user = await ref.watch(userProfileProvider.future);
    final repository = ref.watch(readingListRepositoryProvider);
    return repository.getUserLists(user.idUser);
  },
);
