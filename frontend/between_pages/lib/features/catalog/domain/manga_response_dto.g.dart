// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MangaResponseDTO _$MangaResponseDTOFromJson(Map<String, dynamic> json) =>
    MangaResponseDTO(
      idManga: (MangaResponseDTO._readId(json, 'id') as num?)?.toInt(),
      malId: (json['mal_id'] as num?)?.toInt(),
      malScore: (json['mal_score'] as num?)?.toDouble(),
      source: json['source'] as String?,
      title: json['title'] as String?,
      author: json['author'] as String?,
      demographic: json['demographic'] as String?,
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      totalChapters: (json['total_chapters'] as num?)?.toInt(),
      totalVolumes: (json['total_volumes'] as num?)?.toInt(),
      publicationStatus: json['publicationStatus'] as String?,
    );

Map<String, dynamic> _$MangaResponseDTOToJson(MangaResponseDTO instance) =>
    <String, dynamic>{
      'id': ?instance.idManga,
      'mal_id': ?instance.malId,
      'mal_score': ?instance.malScore,
      'genres': instance.genres,
      'description': ?instance.description,
      'cover_url': ?instance.coverUrl,
      'total_chapters': ?instance.totalChapters,
      'total_volumes': ?instance.totalVolumes,
      'title': instance.title,
      'author': instance.author,
      'source': instance.source,
      'demographic': instance.demographic,
      'publicationStatus': instance.publicationStatus,
    };
