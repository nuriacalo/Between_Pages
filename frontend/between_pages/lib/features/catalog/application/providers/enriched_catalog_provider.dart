import 'package:between_pages/features/catalog/application/providers/all_books_provider.dart';
import 'package:between_pages/features/catalog/application/providers/all_fanfics_provider.dart';
import 'package:between_pages/features/catalog/application/providers/all_manga_provider.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/enriched_catalog_item.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/domain/responses/book_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/fanfic_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/manga_journal_response_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Un proveedor que obtiene todos los items del catálogo del usuario y los
/// enriquece con la información de su journal correspondiente.
final enrichedCatalogProvider = FutureProvider<List<EnrichedCatalogItem>>((ref) async {
  // 1. Obtener todas las fuentes de datos en paralelo.
  final booksFuture = ref.watch(allBooksProvider.future);
  final mangaFuture = ref.watch(allMangaProvider.future);
  final fanficsFuture = ref.watch(allFanficsProvider.future);
  final journalsFuture = ref.watch(allJournalsProvider.future);

  final results = await Future.wait([
    booksFuture,
    mangaFuture,
    fanficsFuture,
    journalsFuture,
  ]);

  // 2. Extraer los resultados.
  final books = results[0] as List<BookResponseDTO>;
  final mangas = results[1] as List<MangaResponseDTO>;
  final fanfics = results[2] as List<FanfictionResponseDTO>;
  final journalsMap = results[3] as Map<dynamic, List<dynamic>>;

  final bookJournals = journalsMap[JournalType.book]?.whereType<BookJournalResponseDto>().toList() ?? [];
  final mangaJournals = journalsMap[JournalType.manga]?.whereType<MangaJournalResponseDTO>().toList() ?? [];
  final fanficJournals = journalsMap[JournalType.fanfic]?.whereType<FanficJournalResponseDTO>().toList() ?? [];

  // 3. Crear mapas de journals para una búsqueda eficiente (O(1)).
  final bookJournalMap = {for (var j in bookJournals) j.book.idBook: j};
  final mangaJournalMap = {for (var j in mangaJournals) j.manga?.idManga: j};
  final fanficJournalMap = {for (var j in fanficJournals) j.fanfic.idFanfic: j};

  // 4. Fusionar los datos.
  final enrichedItems = <EnrichedCatalogItem>[];

  for (final book in books) {
    enrichedItems.add(EnrichedCatalogItem(
      item: book,
      journal: bookJournalMap[book.idBook],
    ));
  }

  for (final manga in mangas) {
    enrichedItems.add(EnrichedCatalogItem(
      item: manga,
      journal: mangaJournalMap[manga.idManga],
    ));
  }

  for (final fanfic in fanfics) {
    enrichedItems.add(EnrichedCatalogItem(
      item: fanfic,
      journal: fanficJournalMap[fanfic.idFanfic],
    ));
  }

  return enrichedItems;
});
