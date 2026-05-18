import 'package:json_annotation/json_annotation.dart';

part 'note_dto.g.dart';

@JsonSerializable()
class NoteDTO {
  final int? id;
  final int userId;
  final String itemType;
  final int itemId;
  final String? quote;
  final String? note;
  final int? page;
  final DateTime? createdAt;

  NoteDTO({
    this.id,
    required this.userId,
    required this.itemType,
    required this.itemId,
    this.quote,
    this.note,
    this.page,
    this.createdAt,
  });

  factory NoteDTO.fromJson(Map<String, dynamic> json) => _$NoteDTOFromJson(json);
  Map<String, dynamic> toJson() => _$NoteDTOToJson(this);
}