// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserResponseDTO _$UserResponseDTOFromJson(Map<String, dynamic> json) =>
    UserResponseDTO(
      idUser: (UserResponseDTO._readId(json, 'id') as num).toInt(),
      name: json['name'] as String? ?? 'Usuario',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'USER',
    );

Map<String, dynamic> _$UserResponseDTOToJson(UserResponseDTO instance) =>
    <String, dynamic>{
      'id': instance.idUser,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
    };
