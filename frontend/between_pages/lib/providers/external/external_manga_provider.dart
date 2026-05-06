import 'package:between_pages/repositories/external_manga_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final externalMangaProvider = FutureProvider.family((ref, String malId) async {
  final repo = ref.read(externalMangaRepositoryProvider);
  return (repo as dynamic).getMangaByMalId(malId);
});

final trendingMangaProvider = FutureProvider((ref) async {
  final repo = ref.read(externalMangaRepositoryProvider);
  return (repo as dynamic).getTrendingManga();
});
