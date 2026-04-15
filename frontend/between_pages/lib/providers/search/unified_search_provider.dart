import 'package:between_pages/models/catalog/book_response_dto.dart';
import 'package:between_pages/models/catalog/fanfiction_response_dto.dart';
import 'package:between_pages/models/catalog/manga_response_dto.dart';
import 'package:between_pages/repositories/book_search_repository.dart';
import 'package:between_pages/repositories/fanfic_search_repository.dart';
import 'package:between_pages/repositories/manga_search_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tipos de contenido para búsqueda
enum SearchContentType { books, fanfics, manga }

/// Estado de la búsqueda unificada
class UnifiedSearchState {
  final String query;
  final SearchContentType contentType;
  final List<BookResponseDTO> bookResults;
  final List<FanfictionResponseDTO> fanficResults;
  final List<MangaResponseDTO> mangaResults;
  final bool isLoading;
  final String? error;

  const UnifiedSearchState({
    this.query = '',
    this.contentType = SearchContentType.books,
    this.bookResults = const [],
    this.fanficResults = const [],
    this.mangaResults = const [],
    this.isLoading = false,
    this.error,
  });

  UnifiedSearchState copyWith({
    String? query,
    SearchContentType? contentType,
    List<BookResponseDTO>? bookResults,
    List<FanfictionResponseDTO>? fanficResults,
    List<MangaResponseDTO>? mangaResults,
    bool? isLoading,
    String? error,
  }) {
    return UnifiedSearchState(
      query: query ?? this.query,
      contentType: contentType ?? this.contentType,
      bookResults: bookResults ?? this.bookResults,
      fanficResults: fanficResults ?? this.fanficResults,
      mangaResults: mangaResults ?? this.mangaResults,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier para manejar la búsqueda unificada
class UnifiedSearchNotifier extends StateNotifier<UnifiedSearchState> {
  final BookSearchRepository _bookRepo;
  final FanficSearchRepository _fanficRepo;
  final MangaSearchRepository _mangaRepo;

  UnifiedSearchNotifier(this._bookRepo, this._fanficRepo, this._mangaRepo)
    : super(const UnifiedSearchState());

  /// Actualiza el texto de búsqueda
  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  /// Cambia el tipo de contenido activo
  void setContentType(SearchContentType type) {
    state = state.copyWith(contentType: type);
    // Si hay query y no hay resultados para este tipo, buscar automáticamente
    if (state.query.isNotEmpty) {
      switch (type) {
        case SearchContentType.books:
          if (state.bookResults.isEmpty) search();
          break;
        case SearchContentType.fanfics:
          if (state.fanficResults.isEmpty) search();
          break;
        case SearchContentType.manga:
          if (state.mangaResults.isEmpty) search();
          break;
      }
    }
  }

  /// Ejecuta la búsqueda según el tipo de contenido activo
  Future<void> search([String? query]) async {
    final searchQuery = (query ?? state.query).trim();
    if (searchQuery.isEmpty) {
      state = state.copyWith(
        bookResults: [],
        fanficResults: [],
        mangaResults: [],
        error: null,
      );
      return;
    }

    // Actualizar query en el estado si se proporcionó
    if (query != null) {
      state = state.copyWith(query: searchQuery, isLoading: true, error: null);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      switch (state.contentType) {
        case SearchContentType.books:
          final results = await _bookRepo.searchBooks(searchQuery);
          state = state.copyWith(bookResults: results, isLoading: false);
          break;
        case SearchContentType.fanfics:
          final results = await _fanficRepo.searchFanfics(searchQuery);
          state = state.copyWith(fanficResults: results, isLoading: false);
          break;
        case SearchContentType.manga:
          final results = await _mangaRepo.searchManga(searchQuery);
          state = state.copyWith(mangaResults: results, isLoading: false);
          break;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Limpia todos los resultados
  void clear() {
    state = const UnifiedSearchState();
  }
}

/// Provider principal de búsqueda unificada
final unifiedSearchProvider =
    StateNotifierProvider<UnifiedSearchNotifier, UnifiedSearchState>((ref) {
      final bookRepo = ref.watch(bookSearchRepositoryProvider);
      final fanficRepo = ref.watch(fanficSearchRepositoryProvider);
      final mangaRepo = ref.watch(mangaSearchRepositoryProvider);
      return UnifiedSearchNotifier(bookRepo, fanficRepo, mangaRepo);
    });
