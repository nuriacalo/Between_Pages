import 'package:json_annotation/json_annotation.dart';

part 'reading_list_request_dto.g.dart';

/// DTO para solicitar la creación de una nueva lista de lectura.
@JsonSerializable(includeIfNull: false)
class ReadingListRequestDTO {
  final String name;
  final String? description;

  ReadingListRequestDTO({
    required this.name,
    this.description,
  });

  factory ReadingListRequestDTO.fromJson(Map<String, dynamic> json) => 
      _$ReadingListRequestDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingListRequestDTOToJson(this);
}
