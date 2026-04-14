// Proveedor que obtiene la lista de libros desde el backend
import 'package:between_pages/models/catalog/book_response_dto.dart';
import 'package:between_pages/repositories/book_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:between_pages/providers/user/user_provider.dart';

final bookProvider = FutureProvider<List<BookResponseDTO>>((ref) async {
  // 1. Obtenemos el usuario actual para extraer su ID
  final user = await ref.watch(userProfileProvider.future);

  // 2. Pedimos los libros de SU journal personal
  final bookRepository = ref.watch(bookRepositoryProvider);
  return await bookRepository.getUserBooks(user.idUser);
});
