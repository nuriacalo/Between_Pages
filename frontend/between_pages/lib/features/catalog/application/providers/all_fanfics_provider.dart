import 'package:between_pages/features/profile/application/providers/user_provider.dart';
import 'package:between_pages/features/catalog/application/repositories/catalog_repository.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final allFanficsProvider = FutureProvider<List<FanfictionResponseDTO>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  final catalogRepository = ref.watch(catalogRepositoryProvider);
  return await catalogRepository.getAllFanfics(user.idUser);
});
