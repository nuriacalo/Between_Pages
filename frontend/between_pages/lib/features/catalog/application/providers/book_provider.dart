import 'package:between_pages/features/catalog/application/repositories/catalog_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookProvider = FutureProvider.family((ref, String googleBooksId) async {
  final catalogRepo = ref.read(catalogRepositoryProvider);
  return catalogRepo.getBookByGoogleId(googleBooksId);
});
