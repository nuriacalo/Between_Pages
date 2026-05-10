import 'package:between_pages/features/catalog/application/repositories/external_manga_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final externalMangaProvider = FutureProvider.family((ref, String malId) async {
  final repo = ref.read(externalMangaRepositoryProvider);
  return repo.getMangaById(int.parse(malId));
});

// Commented out since getTrendingManga is not implemented in the repository
// final trendingMangaProvider = FutureProvider((ref) async {
//   final repo = ref.read(externalMangaRepositoryProvider);
//   return repo.getTrendingManga();
// });
