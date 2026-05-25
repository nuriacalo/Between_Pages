// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoteDTO _$NoteDTOFromJson(Map<String, dynamic> json) => NoteDTO(
  id: (json['id'] as num?)?.toInt(),
  itemType: json['itemType'] as String,
  itemId: (json['itemId'] as num).toInt(),
  quote: json['quote'] as String?,
  note: json['note'] as String?,
  page: (json['page'] as num?)?.toInt(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$NoteDTOToJson(NoteDTO instance) => <String, dynamic>{
  'id': ?instance.id,
  'itemType': instance.itemType,
  'itemId': instance.itemId,
  'quote': ?instance.quote,
  'note': ?instance.note,
  'page': ?instance.page,
  'createdAt': ?instance.createdAt?.toIso8601String(),
};
