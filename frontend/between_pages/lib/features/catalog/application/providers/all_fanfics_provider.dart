import 'package:between_pages/models/catalog/fanfiction_response_dto.dart';
import 'package:between_pages/repositories/catalog_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final allFanficsProvider = FutureProvider<List<FanfictionResponseDTO>>((ref) async {
  final catalogRepository = ref.watch(catalogRepositoryProvider);
  return await catalogRepository.getAllFanfics();
});
