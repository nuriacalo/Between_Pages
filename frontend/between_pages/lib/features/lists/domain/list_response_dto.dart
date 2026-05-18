import 'package:json_annotation/json_annotation.dart';

part 'list_response_dto.g.dart';

@JsonSerializable()
class ListResponseDTO {
  @JsonKey(readValue: _readId)
  final int id;
  
  final String name;
  final String? description;

  ListResponseDTO({required this.id, required this.name, this.description});

  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    return int.tryParse(json['id']?.toString() ?? '0') ?? 0;
  }

  factory ListResponseDTO.fromJson(Map<String, dynamic> json) => 
      _$ListResponseDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ListResponseDTOToJson(this);
}
