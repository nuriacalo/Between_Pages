import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/catalog/domain/media_item.dart';

class ListItemResponseDTO {
  final int id;
  final String itemType;
  final int position;
  final BookResponseDTO? book;
  final MangaResponseDTO? manga;
  final FanfictionResponseDTO? fanfic;

  const ListItemResponseDTO({
    required this.id,
    required this.itemType,
    required this.position,
    this.book,
    this.manga,
    this.fanfic,
  });

  factory ListItemResponseDTO.fromJson(Map<String, dynamic> json) {
    return ListItemResponseDTO(
      id: json['id'],
      itemType: json['item_type'],
      position: json['position'],
      book: json['book'] != null ? BookResponseDTO.fromJson(json['book']) : null,
      manga: json['manga'] != null ? MangaResponseDTO.fromJson(json['manga']) : null,
      fanfic: json['fanfic'] != null ? FanfictionResponseDTO.fromJson(json['fanfic']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'item_type': itemType,
        'position': position,
        'book': book?.toJson(),
        'manga': manga?.toJson(),
        'fanfic': fanfic?.toJson(),
      };

  /// Devuelve el objeto de contenido (Book, Manga o Fanfic) como un [MediaItem] genérico.
  /// Simplifica el acceso al contenido sin tener que hacer un switch/case externo.
  MediaItem? get mediaItem {
    switch (itemType.toUpperCase()) {
      case 'BOOK': return book;
      case 'MANGA': return manga;
      case 'FANFIC': return fanfic;
      default: return null;
    }
  }
}
