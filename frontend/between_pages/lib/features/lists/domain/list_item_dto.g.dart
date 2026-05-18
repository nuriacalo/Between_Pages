// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListItemDTO _$ListItemDTOFromJson(Map<String, dynamic> json) => ListItemDTO(
  id: (ListItemDTO._readId(json, 'id') as num).toInt(),
  itemType: ListItemDTO._readItemType(json, 'item_type') as String,
  position: (json['position'] as num?)?.toInt(),
  book: json['book'] == null
      ? null
      : BookResponseDTO.fromJson(json['book'] as Map<String, dynamic>),
  manga: json['manga'] == null
      ? null
      : MangaResponseDTO.fromJson(json['manga'] as Map<String, dynamic>),
  fanfic: json['fanfic'] == null
      ? null
      : FanfictionResponseDTO.fromJson(json['fanfic'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ListItemDTOToJson(ListItemDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_type': instance.itemType,
      'position': ?instance.position,
      'book': ?instance.book?.toJson(),
      'manga': ?instance.manga?.toJson(),
      'fanfic': ?instance.fanfic?.toJson(),
    };
