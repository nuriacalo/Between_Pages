import 'package:between_pages/repositories/book_search_repository.dart';
import 'package:between_pages/repositories/catalog_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookProvider = FutureProvider.family((ref, String googleBooksId) async {
  final searchRepo = ref.read(bookSearchRepositoryProvider);
  return searchRepo.getBookByGoogleId(googleBooksId);
});

final allBooksProvider = FutureProvider((ref) async {
  final catalogRepo = ref.read(catalogRepositoryProvider);
  return catalogRepo.getAllBooks();
});
