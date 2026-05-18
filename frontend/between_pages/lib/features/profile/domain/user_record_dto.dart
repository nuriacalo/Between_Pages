import 'package:json_annotation/json_annotation.dart';

part 'user_record_dto.g.dart';

@JsonSerializable()
class UserRegistrationDTO {
  final String name;
  final String email;
  final String password;

  UserRegistrationDTO({
    required this.name,
    required this.email,
    required this.password,
  });

  factory UserRegistrationDTO.fromJson(Map<String, dynamic> json) => 
      _$UserRegistrationDTOFromJson(json);

  Map<String, dynamic> toJson() => _$UserRegistrationDTOToJson(this);
}
