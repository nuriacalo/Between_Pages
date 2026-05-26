// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fanfiction_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FanfictionResponseDTO _$FanfictionResponseDTOFromJson(
  Map<String, dynamic> json,
) => FanfictionResponseDTO(
  idFanfic: (FanfictionResponseDTO._readId(json, 'id') as num?)?.toInt(),
  ao3Id: json['ao3Id'] as String?,
  title: json['title'] as String?,
  author: json['author'] as String?,
  sourceMaterial: json['sourceMaterial'] as String?,
  description: json['description'] as String?,
  coverUrl: json['coverUrl'] as String?,
  genres:
      (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  mainShip: json['mainShip'] as String?,
  theme: json['theme'] as String?,
  currentChapter: (json['currentChapter'] as num?)?.toInt(),
  totalChapters: (json['totalChapters'] as num?)?.toInt(),
  publicationStatus: json['publicationStatus'] as String?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$FanfictionResponseDTOToJson(
  FanfictionResponseDTO instance,
) => <String, dynamic>{
  'id': ?instance.idFanfic,
  'ao3Id': ?instance.ao3Id,
  'sourceMaterial': ?instance.sourceMaterial,
  'description': ?instance.description,
  'coverUrl': ?instance.coverUrl,
  'genres': instance.genres,
  'mainShip': ?instance.mainShip,
  'theme': ?instance.theme,
  'currentChapter': ?instance.currentChapter,
  'totalChapters': ?instance.totalChapters,
  'publicationStatus': ?instance.publicationStatus,
  'tags': ?instance.tags,
  'title': instance.title,
  'author': instance.author,
};
