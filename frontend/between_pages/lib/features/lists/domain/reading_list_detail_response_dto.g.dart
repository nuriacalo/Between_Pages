// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_list_detail_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingListDetailResponseDTO _$ReadingListDetailResponseDTOFromJson(
  Map<String, dynamic> json,
) => ReadingListDetailResponseDTO(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  items: (json['items'] as List<dynamic>)
      .map((e) => ListItemResponseDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ReadingListDetailResponseDTOToJson(
  ReadingListDetailResponseDTO instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'items': instance.items,
};
