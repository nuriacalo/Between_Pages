// Proveedor que obtiene la lista de libros desde el backend
import 'package:between_pages/models/catalog/book_response_dto.dart';
import 'package:between_pages/repositories/book_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookProvider = FutureProvider<List<BookResponseDTO>>((ref) async {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return await bookRepository.getBooks();
});