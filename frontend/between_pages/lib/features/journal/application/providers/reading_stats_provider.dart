import 'package:between_pages/repositories/reading_session_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Immutable parameters for reading stats provider.
/// Implements == and hashCode so Riverpod can properly cache family instances.
class ReadingStatsParams {
  final int? bookId;
  final int? mangaId;
  final int? fanficId;
  final int remainingPages;

  const ReadingStatsParams({
    this.bookId,
    this.mangaId,
    this.fanficId,
    this.remainingPages = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingStatsParams &&
          runtimeType == other.runtimeType &&
          bookId == other.bookId &&
          mangaId == other.mangaId &&
          fanficId == other.fanficId &&
          remainingPages == other.remainingPages;

  @override
  int get hashCode =>
      bookId.hashCode ^
      mangaId.hashCode ^
      fanficId.hashCode ^
      remainingPages.hashCode;
}

final itemReadingStatsProvider =
    FutureProvider.family<Map<String, dynamic>, ReadingStatsParams>((
      ref,
      params,
    ) async {
      final repo = ref.watch(readingSessionRepositoryProvider);
      return repo.getItemStats(
        bookId: params.bookId,
        mangaId: params.mangaId,
        fanficId: params.fanficId,
        remainingPages: params.remainingPages,
      );
    });
