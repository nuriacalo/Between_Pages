import 'package:json_annotation/json_annotation.dart';

part 'list_record_dto.g.dart';

@JsonSerializable()
class ListaRecordDTO {
  @JsonKey(name: 'user_id', readValue: _readUserId)
  final int userId;
  
  final String name;
  final String? description;

  ListaRecordDTO({required this.userId, required this.name, this.description});

  static Object? _readUserId(Map<dynamic, dynamic> json, String key) {
    return int.tryParse(json['user_id']?.toString() ?? '0') ?? 0;
  }

  factory ListaRecordDTO.fromJson(Map<String, dynamic> json) => 
      _$ListaRecordDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ListaRecordDTOToJson(this);
}
