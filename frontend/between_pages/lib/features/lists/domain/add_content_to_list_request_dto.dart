import 'package:json_annotation/json_annotation.dart';

part 'add_content_to_list_request_dto.g.dart';

@JsonSerializable()
class AddContentToListRequestDTO {
  @JsonKey(name: 'contentId')
  final int contentId;

  @JsonKey(name: 'contentType')
  final String contentType; // "BOOK", "MANGA", "FANFIC"

  AddContentToListRequestDTO({
    required this.contentId,
    required this.contentType,
  });

  factory AddContentToListRequestDTO.fromJson(Map<String, dynamic> json) =>
      _$AddContentToListRequestDTOFromJson(json);

  Map<String, dynamic> toJson() => _$AddContentToListRequestDTOToJson(this);
}
