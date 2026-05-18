import 'package:json_annotation/json_annotation.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';

part 'list_item_dto.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ListItemDTO {
  @JsonKey(readValue: _readId)
  final int id;
  
  @JsonKey(name: 'item_type', readValue: _readItemType)
  final String itemType;
  
  final int? position;

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

  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    return int.tryParse(json['id']?.toString() ?? '0') ?? 0;
  }

  static Object? _readItemType(Map<dynamic, dynamic> json, String key) {
    return json['item_type'] ?? json['itemType'] ?? '';
  }

  factory ListItemDTO.fromJson(Map<String, dynamic> json) => 
      _$ListItemDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ListItemDTOToJson(this);

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
