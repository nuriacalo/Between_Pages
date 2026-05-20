// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_content_to_list_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddContentToListRequestDTO _$AddContentToListRequestDTOFromJson(
  Map<String, dynamic> json,
) => AddContentToListRequestDTO(
  contentId: (json['contentId'] as num).toInt(),
  contentType: json['contentType'] as String,
);

Map<String, dynamic> _$AddContentToListRequestDTOToJson(
  AddContentToListRequestDTO instance,
) => <String, dynamic>{
  'contentId': instance.contentId,
  'contentType': instance.contentType,
};
