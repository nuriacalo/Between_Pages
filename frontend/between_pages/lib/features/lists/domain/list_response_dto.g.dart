// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListResponseDTO _$ListResponseDTOFromJson(Map<String, dynamic> json) =>
    ListResponseDTO(
      id: (ListResponseDTO._readId(json, 'id') as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$ListResponseDTOToJson(ListResponseDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
    };
