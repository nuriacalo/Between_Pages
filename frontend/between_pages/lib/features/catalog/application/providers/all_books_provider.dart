import 'package:between_pages/features/catalog/application/repositories/catalog_repository.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final allBooksProvider = FutureProvider<List<BookResponseDTO>>((ref) async {
  final catalogRepository = ref.watch(catalogRepositoryProvider);
  return await catalogRepository.getAllBooks();
});
