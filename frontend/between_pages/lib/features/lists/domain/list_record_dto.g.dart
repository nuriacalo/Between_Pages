// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_record_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListaRecordDTO _$ListaRecordDTOFromJson(Map<String, dynamic> json) =>
    ListaRecordDTO(
      userId: (ListaRecordDTO._readUserId(json, 'user_id') as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$ListaRecordDTOToJson(ListaRecordDTO instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'name': instance.name,
      'description': instance.description,
    };
