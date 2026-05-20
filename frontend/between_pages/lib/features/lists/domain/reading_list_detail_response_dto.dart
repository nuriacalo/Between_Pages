import 'package:json_annotation/json_annotation.dart';

import 'list_item_response_dto.dart';

// Duplicate import removed (kept single import).

part 'reading_list_detail_response_dto.g.dart';

@JsonSerializable()
class ReadingListDetailResponseDTO {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'items')
  final List<ListItemResponseDTO> items;

  const ReadingListDetailResponseDTO({
    required this.id,
    required this.name,
    required this.description,
    required this.items,
  });

  factory ReadingListDetailResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$ReadingListDetailResponseDTOFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReadingListDetailResponseDTOToJson(this);
}

