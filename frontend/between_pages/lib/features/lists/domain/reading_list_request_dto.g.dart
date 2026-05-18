// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_list_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingListRequestDTO _$ReadingListRequestDTOFromJson(
  Map<String, dynamic> json,
) => ReadingListRequestDTO(
  name: json['name'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$ReadingListRequestDTOToJson(
  ReadingListRequestDTO instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': ?instance.description,
};
