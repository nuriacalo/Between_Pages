import 'package:between_pages/features/profile/application/repositories/reading_stats_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemStatsParams extends Equatable {
  final int? itemId;
  final int remainingPages;
  final String itemType;

  const ItemStatsParams({
    required this.itemId,
    required this.remainingPages,
    required this.itemType,
  });

  @override
  List<Object?> get props => [itemId, remainingPages, itemType];
}

final itemReadingStatsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, ItemStatsParams>((ref, params) async {
  if (params.itemId == null) {
    return {};
  }
  final repo = ref.watch(readingStatsRepositoryProvider);
  return repo.getItemReadingStats(params.itemId!, params.itemType);
});