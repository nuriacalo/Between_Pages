import 'package:between_pages/features/catalog/application/repositories/book_search_repository.dart';
import 'package:between_pages/features/catalog/application/repositories/external_book_repository.dart';
import 'package:between_pages/features/catalog/application/repositories/fanfic_search_repository.dart';
import 'package:between_pages/features/catalog/application/repositories/manga_search_repository.dart';
import 'package:between_pages/features/catalog/application/repositories/external_manga_repository.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
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
  final ExternalBookRepository _externalBookRepo;
  final FanficSearchRepository _fanficRepo;
  final MangaSearchRepository _mangaRepo;
  final ExternalMangaRepository _externalMangaRepo;


  UnifiedSearchNotifier(
    this._bookRepo,
    this._externalBookRepo,
    this._fanficRepo,
    this._mangaRepo,
    this._externalMangaRepo,
  ) : super(const UnifiedSearchState());

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
          final localResults = await _bookRepo.searchBooks(searchQuery);
          final googleResults = await _externalBookRepo.searchBooks(searchQuery);

          // Queremos mezclar pero garantizando que si existe en BBDD se use el local.
          // Regla:
          // - si googleBooksId existe en BBDD => reemplazar con el local
          // - si no existe => mantener el resultado de Google
          final localByGoogleId = <String, BookResponseDTO>{
            for (final b in localResults)
              if (b.googleBooksId.isNotEmpty) b.googleBooksId: b,
          };

          final merged = <BookResponseDTO>[];
          final seenGoogleIds = <String>{};

          for (final g in googleResults) {
            final gid = g.googleBooksId;
            if (gid.isEmpty) {
              // Si no hay googleBooksId no podemos deduplicar; lo añadimos.
              merged.add(g);
              continue;
            }

            seenGoogleIds.add(gid);

            final local = localByGoogleId[gid];
            merged.add(local ?? g);
          }

          // Añadimos también los locales que no vinieron en Google.
          // (por ejemplo si Google no devolvió ese libro para el query)
          for (final l in localResults) {
            final gid = l.googleBooksId;
            if (gid.isEmpty) {
              // No deduplicable, lo añadimos
              merged.add(l);
              continue;
            }
            if (!seenGoogleIds.contains(gid)) {
              merged.add(l);
            }
          }

          state = state.copyWith(bookResults: merged, isLoading: false);
          break;
        case SearchContentType.fanfics:
          final results = await _fanficRepo.searchFanfics(searchQuery);
          state = state.copyWith(fanficResults: results, isLoading: false);
          break;
        case SearchContentType.manga:
          final localResults = await _mangaRepo.searchManga(searchQuery);
          final externalResults = await _externalMangaRepo.searchManga(searchQuery);

          // Mezclamos usando malId cuando exista. Si malId es nulo, no deduplicamos.
          final localByMalId = <int, MangaResponseDTO>{
            for (final m in localResults)
              if (m.malId != null) m.malId!: m,
          };

          final merged = <MangaResponseDTO>[];
          final seenMalIds = <int>{};

          for (final e in externalResults) {
            final malId = e.malId;
            if (malId == null) {
              merged.add(e);
              continue;
            }

            seenMalIds.add(malId);
            merged.add(localByMalId[malId] ?? e);
          }

          for (final l in localResults) {
            final malId = l.malId;
            if (malId == null) {
              merged.add(l);
              continue;
            }
            if (!seenMalIds.contains(malId)) {
              merged.add(l);
            }
          }

          state = state.copyWith(mangaResults: merged, isLoading: false);
          break;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Limpia todos los resultados
  void clear() {
    state = state.copyWith(
      query: '',
      bookResults: [],
      fanficResults: [],
      mangaResults: [],
      error: null,
    );
  }
}

/// Provider principal de búsqueda unificada
final unifiedSearchProvider =
    StateNotifierProvider<UnifiedSearchNotifier, UnifiedSearchState>((ref) {
      final bookRepo = ref.watch(bookSearchRepositoryProvider);
      final externalBookRepo = ref.watch(externalBookRepositoryProvider);
      final fanficRepo = ref.watch(fanficSearchRepositoryProvider);
      final mangaRepo = ref.watch(mangaSearchRepositoryProvider);
      final externalMangaRepo = ref.watch(externalMangaRepositoryProvider);
      return UnifiedSearchNotifier(
        bookRepo,
        externalBookRepo,
        fanficRepo,
        mangaRepo,
        externalMangaRepo,
      );
    });
