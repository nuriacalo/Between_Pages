import 'package:between_pages/models/catalog/manga_response_dto.dart';
import 'package:between_pages/repositories/external_manga_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado para la búsqueda de manga externo (MyAnimeList vía Jikan)
class ExternalMangaSearchState {
  final List<MangaResponseDTO> results;
  final bool isLoading;
  final String? error;
  final String? lastQuery;

  const ExternalMangaSearchState({
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.lastQuery,
  });

  ExternalMangaSearchState copyWith({
    List<MangaResponseDTO>? results,
    bool? isLoading,
    String? error,
    String? lastQuery,
  }) {
    return ExternalMangaSearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastQuery: lastQuery ?? this.lastQuery,
    );
  }
}

/// Notifier para manejar la búsqueda de manga externo
class ExternalMangaSearchNotifier
    extends StateNotifier<ExternalMangaSearchState> {
  final ExternalMangaRepository _repository;

  ExternalMangaSearchNotifier(this._repository)
    : super(const ExternalMangaSearchState());

  /// Busca manga externo por título
  Future<void> searchManga(String query, {int page = 1}) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(results: [], error: null);
      return;
    }

    state = state.copyWith(isLoading: true, error: null, lastQuery: query);

    try {
      final results = await _repository.searchManga(query, page: page);
      state = state.copyWith(results: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Limpia los resultados
  void clearResults() {
    state = const ExternalMangaSearchState();
  }
}

// ============================================
// PROVIDERS
// ============================================

/// Provider principal para búsqueda de manga externo
final externalMangaSearchProvider =
    StateNotifierProvider<
      ExternalMangaSearchNotifier,
      ExternalMangaSearchState
    >((ref) {
      final repository = ref.watch(externalMangaRepositoryProvider);
      return ExternalMangaSearchNotifier(repository);
    });

/// Provider para resultados de búsqueda
final externalMangaSearchResultsProvider = Provider<List<MangaResponseDTO>>(
  (ref) => ref.watch(externalMangaSearchProvider).results,
);

/// Provider para estado de carga
final externalMangaSearchLoadingProvider = Provider<bool>(
  (ref) => ref.watch(externalMangaSearchProvider).isLoading,
);

/// Provider para errores
final externalMangaSearchErrorProvider = Provider<String?>(
  (ref) => ref.watch(externalMangaSearchProvider).error,
);
