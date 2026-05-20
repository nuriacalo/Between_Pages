// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_session_record_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingSessionRecordDTO _$ReadingSessionRecordDTOFromJson(
  Map<String, dynamic> json,
) => ReadingSessionRecordDTO(
  userId: (json['userId'] as num).toInt(),
  bookId: (json['bookId'] as num?)?.toInt(),
  mangaId: (json['mangaId'] as num?)?.toInt(),
  fanficId: (json['fanficId'] as num?)?.toInt(),
  durationSeconds: (json['durationSeconds'] as num).toInt(),
  pagesRead: (json['pagesRead'] as num).toInt(),
);

Map<String, dynamic> _$ReadingSessionRecordDTOToJson(
  ReadingSessionRecordDTO instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'bookId': ?instance.bookId,
  'mangaId': ?instance.mangaId,
  'fanficId': ?instance.fanficId,
  'durationSeconds': instance.durationSeconds,
  'pagesRead': instance.pagesRead,
};
