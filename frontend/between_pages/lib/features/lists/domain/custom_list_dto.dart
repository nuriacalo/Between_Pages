import 'package:json_annotation/json_annotation.dart';
import 'package:between_pages/features/lists/domain/list_item_dto.dart';

part 'custom_list_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class CustomListDTO {
  @JsonKey(readValue: _readId)
  final int id;
  
  final String name;
  final String? description;
  
  @JsonKey(defaultValue: [])
  final List<ListItemDTO> items;

  CustomListDTO({
    required this.id,
    required this.name,
    this.description,
    required this.items,
  });

  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    return int.tryParse(json['id']?.toString() ?? '0') ?? 0;
  }

  factory CustomListDTO.fromJson(Map<String, dynamic> json) => 
      _$CustomListDTOFromJson(json);

  Map<String, dynamic> toJson() => _$CustomListDTOToJson(this);
}
