import 'package:between_pages/features/catalog/application/repositories/book_search_repository.dart';
import 'package:between_pages/features/catalog/application/repositories/fanfic_search_repository.dart';
import 'package:between_pages/features/catalog/application/repositories/manga_search_repository.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enum para definir el tipo de contenido que se está buscando
enum SearchContentType { book, fanfic, manga }

// Estado para el proveedor de búsqueda unificada
class UnifiedSearchState {
  final bool isLoading;
  final String? error;
  final String query;
  final SearchContentType contentType;
  final List<BookResponseDTO> bookResults;
  final List<MangaResponseDTO> mangaResults;
  final List<FanfictionResponseDTO> fanficResults;

  UnifiedSearchState({
    this.isLoading = false,
    this.error,
    this.query = '',
    this.contentType = SearchContentType.book,
    this.bookResults = const [],
    this.mangaResults = const [],
    this.fanficResults = const [],
  });

  // Estado inicial
  factory UnifiedSearchState.initial() => UnifiedSearchState();

  // Método para crear una copia del estado con valores actualizados
  UnifiedSearchState copyWith({
    bool? isLoading,
    String? error,
    String? query,
    SearchContentType? contentType,
    List<BookResponseDTO>? bookResults,
    List<MangaResponseDTO>? mangaResults,
    List<FanfictionResponseDTO>? fanficResults,
  }) {
    return UnifiedSearchState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // No se mantiene el error anterior
      query: query ?? this.query,
      contentType: contentType ?? this.contentType,
      bookResults: bookResults ?? this.bookResults,
      mangaResults: mangaResults ?? this.mangaResults,
      fanficResults: fanficResults ?? this.fanficResults,
    );
  }
}

// Notificador para la búsqueda unificada
class UnifiedSearchNotifier extends StateNotifier<UnifiedSearchState> {
  final BookSearchRepository _bookRepository;
  final MangaSearchRepository _mangaRepository;
  final FanficSearchRepository _fanficRepository;

  UnifiedSearchNotifier({
    required BookSearchRepository bookRepository,
    required MangaSearchRepository mangaRepository,
    required FanficSearchRepository fanficRepository,
  })  : _bookRepository = bookRepository,
        _mangaRepository = mangaRepository,
        _fanficRepository = fanficRepository,
        super(UnifiedSearchState.initial());

  /// Ejecuta una búsqueda para la query y el tipo de contenido actual.
  Future<void> search(String query) async {
    if (query.isEmpty) {
      clear();
      return;
    }

    final queryChanged = query != state.query;

    state = state.copyWith(
      isLoading: true, 
      error: null, 
      query: query,
      bookResults: queryChanged ? [] : state.bookResults,
      mangaResults: queryChanged ? [] : state.mangaResults,
      fanficResults: queryChanged ? [] : state.fanficResults,
    );

    try {
      switch (state.contentType) {
        case SearchContentType.book:
          await _searchBooks(query);
          break;
        case SearchContentType.manga:
          await _searchManga(query);
          break;
        case SearchContentType.fanfic:
          await _searchFanfics(query);
          break;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Busca libros en la BBDD local y en la fuente externa.
  Future<void> _searchBooks(String query) async {
    final results = await Future.wait([
      _bookRepository.searchBooks(query),
      _bookRepository.searchExternalBooks(query),
    ]);

    final localResults = results[0];
    final externalResults = results[1];

    // Combinar resultados, dando prioridad a los locales y evitando duplicados.
    final allResults = [...localResults];
    final localIds = localResults
        .map((b) => b.googleBooksId)
        .where((id) => id != null && id.isNotEmpty)
        .toSet();

    for (final externalBook in externalResults) {
      final externalId = externalBook.googleBooksId;
      if (externalId != null &&
          externalId.isNotEmpty && !localIds.contains(externalId)) {
        allResults.add(externalBook);
      }
    }

    state = state.copyWith(bookResults: allResults, isLoading: false);
  }

  /// Busca mangas en la BBDD local y en la fuente externa.
  Future<void> _searchManga(String query) async {
    final results = await Future.wait([
      _mangaRepository.searchManga(query),
      _mangaRepository.searchExternalManga(query),
    ]);

    final localResults = results[0];
    final externalResults = results[1];

    // Combinar resultados, evitando duplicados por malId.
    final allResults = [...localResults];
    final localIds =
        localResults.map((m) => m.malId).where((id) => id != null).toSet();

    for (final externalManga in externalResults) {
      if (externalManga.malId != null &&
          !localIds.contains(externalManga.malId)) {
        allResults.add(externalManga);
      }
    }

    // Filtrar para excluir mangas con contenido explícito (Hentai / Erótica)
    final filteredResults = allResults.where((manga) {
      final isExplicitGenre = manga.genres.any((genre) {
        final g = genre.toLowerCase();
        return g.contains('hentai') || g.contains('erotica');
      });
      
      return !isExplicitGenre;
    }).toList();

    state = state.copyWith(mangaResults: filteredResults, isLoading: false);
  }

  /// Busca fanfics (actualmente solo en la BBDD local).
  Future<void> _searchFanfics(String query) async {
    final results = await _fanficRepository.searchFanfics(query);
    state = state.copyWith(fanficResults: results, isLoading: false);
  }

  /// Cambia el tipo de contenido a buscar. Mantiene los resultados cacheados si la query es la misma.
  void setContentType(SearchContentType contentType) {
    if (state.contentType != contentType) {
      state = state.copyWith(
        contentType: contentType,
        error: null,
      );
      
      // Si hay una query, vuelve a buscar con el nuevo tipo SOLO si no hay resultados previos
      if (state.query.isNotEmpty) {
        bool needsSearch = false;
        switch (contentType) {
          case SearchContentType.book:
            needsSearch = state.bookResults.isEmpty;
            break;
          case SearchContentType.manga:
            needsSearch = state.mangaResults.isEmpty;
            break;
          case SearchContentType.fanfic:
            needsSearch = state.fanficResults.isEmpty;
            break;
        }

        if (needsSearch) {
          search(state.query);
        }
      }
    }
  }

  /// Limpia la query y los resultados de búsqueda.
  void clear() {
    state = UnifiedSearchState.initial().copyWith(contentType: state.contentType);
  }
}

// Proveedor de Riverpod
final unifiedSearchProvider =
    StateNotifierProvider<UnifiedSearchNotifier, UnifiedSearchState>((ref) {
  return UnifiedSearchNotifier(
    bookRepository: ref.watch(bookSearchRepositoryProvider),
    mangaRepository: ref.watch(mangaSearchRepositoryProvider),
    fanficRepository: ref.watch(fanficSearchRepositoryProvider),
  );
});