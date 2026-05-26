import 'package:between_pages/features/journal/domain/responses/base_journal_response_dto.dart';

/// Un modelo de datos que combina un item del catálogo (libro, manga, etc.)
/// con su correspondiente entrada en el journal (si existe).
class EnrichedCatalogItem {
  /// El item base del catálogo (ej. BookResponseDTO, MangaResponseDTO).
  final dynamic item;

  /// La entrada del journal asociada. Puede ser null si el item solo está
  /// en el catálogo (ej. en estado TBR o Wishlist sin haber empezado a leer).
  final BaseJournalResponseDTO? journal;

  const EnrichedCatalogItem({
    required this.item,
    this.journal,
  });
}
