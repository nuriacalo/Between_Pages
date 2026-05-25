// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_journal_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MangaJournalResponseDTO _$MangaJournalResponseDTOFromJson(
  Map<String, dynamic> json,
) => MangaJournalResponseDTO(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  manga: json['manga'] == null
      ? null
      : MangaResponseDTO.fromJson(json['manga'] as Map<String, dynamic>),
  status: json['status'] as String,
  currentChapter: (json['currentChapter'] as num?)?.toInt(),
  currentVolume: (json['currentVolume'] as num?)?.toInt(),
  rating: (json['rating'] as num?)?.toInt(),
  tearDrops: (json['tearDrops'] as num?)?.toInt(),
  spiceFlames: (json['spiceFlames'] as num?)?.toInt(),
  readingFormat: json['readingFormat'] as String?,
  favoriteCharacter: json['favoriteCharacter'] as String?,
  favoriteArc: json['favoriteArc'] as String?,
  personalNotes: json['personalNotes'] as String?,
  startDate: json['startDate'] as String?,
  endDate: json['endDate'] as String?,
  rereading: json['rereading'] as bool?,
  ownership: json['ownership'] as String?,
  loanedTo: json['loanedTo'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$MangaJournalResponseDTOToJson(
  MangaJournalResponseDTO instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'status': instance.status,
  'personalNotes': instance.personalNotes,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
  'rating': instance.rating,
  'tearDrops': instance.tearDrops,
  'spiceFlames': instance.spiceFlames,
  'rereading': instance.rereading,
  'ownership': instance.ownership,
  'readingFormat': instance.readingFormat,
  'loanedTo': instance.loanedTo,
  'updatedAt': instance.updatedAt,
  'manga': instance.manga?.toJson(),
  'currentChapter': instance.currentChapter,
  'currentVolume': instance.currentVolume,
  'favoriteCharacter': instance.favoriteCharacter,
  'favoriteArc': instance.favoriteArc,
};
