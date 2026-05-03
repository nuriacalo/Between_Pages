import 'package:between_pages/models/catalog/book_response_dto.dart';
import 'package:between_pages/models/catalog/fanfiction_response_dto.dart';
import 'package:between_pages/models/catalog/manga_response_dto.dart';

class ListItemDTO {
  final int id;
  final String itemType; // 'BOOK', 'MANGA' o 'FANFIC'
  final int? position;

  // Solo uno de estos será no null dependiendo del itemType
  final BookResponseDTO? book;
  final MangaResponseDTO? manga;
  final FanfictionResponseDTO? fanfic;

  ListItemDTO({
    required this.id,
    required this.itemType,
    this.position,
    this.book,
    this.manga,
    this.fanfic,
  });

  factory ListItemDTO.fromJson(Map<String, dynamic> json) {
    final itemType =
        json['item_type'] as String? ?? json['itemType'] as String? ?? '';

    return ListItemDTO(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      itemType: itemType,
      position: json['position'] as int?,
      book: json['book'] != null
          ? BookResponseDTO.fromJson(json['book'])
          : null,
      manga: json['manga'] != null
          ? MangaResponseDTO.fromJson(json['manga'])
          : null,
      fanfic: json['fanfic'] != null
          ? FanfictionResponseDTO.fromJson(json['fanfic'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_type': itemType,
      'position': position,
      'book': book?.toJson(),
      'manga': manga?.toJson(),
      'fanfic': fanfic?.toJson(),
    };
  }

  // Helper para obtener el título según el tipo
  String get title {
    switch (itemType) {
      case 'BOOK':
        return book?.title ?? 'Sin título';
      case 'MANGA':
        return manga?.title ?? 'Sin título';
      case 'FANFIC':
        return fanfic?.title ?? 'Sin título';
      default:
        return 'Sin título';
    }
  }

  // Helper para obtener el autor según el tipo
  String get author {
    switch (itemType) {
      case 'BOOK':
        return book?.author ?? 'Autor desconocido';
      case 'MANGA':
        return manga?.author ?? 'Autor desconocido';
      case 'FANFIC':
        return fanfic?.author ?? 'Autor desconocido';
      default:
        return 'Autor desconocido';
    }
  }

  // Helper para obtener la URL de portada según el tipo
  String? get coverUrl {
    switch (itemType) {
      case 'BOOK':
        return book?.coverUrl;
      case 'MANGA':
        return manga?.coverUrl;
      case 'FANFIC':
        return fanfic?.coverUrl;
      default:
        return null;
    }
  }

  // Helper para obtener el ID del contenido según el tipo
  int get contentId {
    switch (itemType) {
      case 'BOOK':
        return book?.idBook ?? 0;
      case 'MANGA':
        return manga?.idManga ?? 0;
      case 'FANFIC':
        return fanfic?.idFanfic ?? 0;
      default:
        return 0;
    }
  }
}
