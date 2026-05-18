// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fanfiction_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FanfictionResponseDTO _$FanfictionResponseDTOFromJson(
  Map<String, dynamic> json,
) => FanfictionResponseDTO(
  idFanfic: (FanfictionResponseDTO._readId(json, 'id') as num?)?.toInt(),
  ao3Id: json['ao3_id'] as String?,
  title: json['title'] as String?,
  author: json['author'] as String?,
  sourceMaterial: json['source_material'] as String?,
  description: json['description'] as String?,
  coverUrl: json['cover_url'] as String?,
  genres:
      (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  mainShip: json['main_ship'] as String?,
  theme: json['theme'] as String?,
  currentChapter: (json['current_chapter'] as num?)?.toInt(),
  totalChapters: (json['total_chapters'] as num?)?.toInt(),
  publicationStatus: json['publication_status'] as String?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$FanfictionResponseDTOToJson(
  FanfictionResponseDTO instance,
) => <String, dynamic>{
  'id': ?instance.idFanfic,
  'ao3_id': ?instance.ao3Id,
  'source_material': ?instance.sourceMaterial,
  'description': ?instance.description,
  'cover_url': ?instance.coverUrl,
  'genres': instance.genres,
  'main_ship': ?instance.mainShip,
  'theme': ?instance.theme,
  'current_chapter': ?instance.currentChapter,
  'total_chapters': ?instance.totalChapters,
  'publication_status': ?instance.publicationStatus,
  'tags': ?instance.tags,
  'title': instance.title,
  'author': instance.author,
};
