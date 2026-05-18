// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_list_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomListDTO _$CustomListDTOFromJson(Map<String, dynamic> json) =>
    CustomListDTO(
      id: (CustomListDTO._readId(json, 'id') as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => ListItemDTO.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$CustomListDTOToJson(CustomListDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };
