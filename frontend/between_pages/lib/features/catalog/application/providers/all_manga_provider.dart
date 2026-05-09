import 'package:between_pages/models/catalog/manga_response_dto.dart';
import 'package:between_pages/repositories/catalog_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final allMangaProvider = FutureProvider<List<MangaResponseDTO>>((ref) async {
  final catalogRepository = ref.watch(catalogRepositoryProvider);
  return await catalogRepository.getAllManga();
});
