// lib/repositories/manga_journal_repository.dart
import 'package:between_pages/api/api_client.dart';
import 'package:between_pages/models/journal/manga_journal_response_dto.dart';
import 'package:between_pages/providers/auth/api_provider.dart';
import 'package:between_pages/core/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MangaJournalRepository {
  final ApiClient _apiClient;
  MangaJournalRepository(this._apiClient);

  Future<List<MangaJournalResponseDTO>> getMangasForUser(int userId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.mangaJournalUser}$userId',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => MangaJournalResponseDTO.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
        'Backend dice: ${e.response?.statusCode} -> ${e.response?.data ?? e.message}',
      );
    }
  }
}

final mangaJournalRepositoryProvider = Provider<MangaJournalRepository>((ref) {
  return MangaJournalRepository(ref.watch(apiClientProvider));
});
