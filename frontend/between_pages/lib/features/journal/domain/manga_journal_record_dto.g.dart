// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_journal_record_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MangaJournalRecordDTO _$MangaJournalRecordDTOFromJson(
  Map<String, dynamic> json,
) => MangaJournalRecordDTO(
  id: (json['id'] as num?)?.toInt(),
  userId: (MangaJournalRecordDTO._readUserId(json, 'userId') as num).toInt(),
  mangaId: (json['mangaId'] as num?)?.toInt(),
  malId: (json['malId'] as num?)?.toInt(),
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
  ownership: json['ownership'] as String?,
  loanedTo: json['loanedTo'] as String?,
  rereading: json['rereading'] as bool?,
);

Map<String, dynamic> _$MangaJournalRecordDTOToJson(
  MangaJournalRecordDTO instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'userId': instance.userId,
  'mangaId': ?instance.mangaId,
  'malId': ?instance.malId,
  'status': instance.status,
  'currentChapter': ?instance.currentChapter,
  'currentVolume': ?instance.currentVolume,
  'rating': ?instance.rating,
  'tearDrops': ?instance.tearDrops,
  'spiceFlames': ?instance.spiceFlames,
  'readingFormat': ?instance.readingFormat,
  'favoriteCharacter': ?instance.favoriteCharacter,
  'favoriteArc': ?instance.favoriteArc,
  'personalNotes': ?instance.personalNotes,
  'startDate': ?instance.startDate,
  'endDate': ?instance.endDate,
  'ownership': ?instance.ownership,
  'loanedTo': ?instance.loanedTo,
  'rereading': ?instance.rereading,
};
