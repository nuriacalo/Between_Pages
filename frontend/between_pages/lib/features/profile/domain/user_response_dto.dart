import 'package:json_annotation/json_annotation.dart';

part 'user_response_dto.g.dart';

@JsonSerializable()
class UserResponseDTO {
  @JsonKey(name: 'id', readValue: _readId)
  final int idUser;
  
  @JsonKey(defaultValue: 'Usuario')
  final String name;
  
  @JsonKey(defaultValue: '')
  final String email;
  
  @JsonKey(defaultValue: 'USER')
  final String role;

  UserResponseDTO({
    required this.idUser,
    required this.name,
    required this.email,
    required this.role,
  });

  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    return int.tryParse(json['id']?.toString() ?? '0') ?? 0;
  }

  factory UserResponseDTO.fromJson(Map<String, dynamic> json) => 
      _$UserResponseDTOFromJson(json);

  Map<String, dynamic> toJson() => _$UserResponseDTOToJson(this);
}
