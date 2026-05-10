import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/catalog/application/repositories/catalog_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final allMangaProvider = FutureProvider<List<MangaResponseDTO>>((ref) async {
  final catalogRepository = ref.watch(catalogRepositoryProvider);
  return await catalogRepository.getAllManga();
});
