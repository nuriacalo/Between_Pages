import 'package:json_annotation/json_annotation.dart';

part 'note_dto.g.dart';

@JsonSerializable(
  // Tells json_serializable to use null when a field is absent
  // instead of throwing. Safer for API responses.
  includeIfNull: false,
)
class NoteDTO {
  final int?      id;
  final String    itemType;
  final int       itemId;
  final String?   quote;
  final String?   note;
  final int?      page;

  // json_serializable handles DateTime <-> ISO-8601 string automatically.
  // If your API returns a different format (e.g. epoch millis), add:
  // @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? createdAt;

  const NoteDTO({
    this.id,
    required this.itemType,
    required this.itemId,
    this.quote,
    this.note,
    this.page,
    this.createdAt,
  });

  factory NoteDTO.fromJson(Map<String, dynamic> json) =>
      _$NoteDTOFromJson(json);

  Map<String, dynamic> toJson() => _$NoteDTOToJson(this);

  NoteDTO copyWith({
    int?      id,
    String?   itemType,
    int?      itemId,
    String?   quote,
    String?   note,
    int?      page,
    DateTime? createdAt,
  }) =>
      NoteDTO(
        id:        id        ?? this.id,
        itemType:  itemType  ?? this.itemType,
        itemId:    itemId    ?? this.itemId,
        quote:     quote     ?? this.quote,
        note:      note      ?? this.note,
        page:      page      ?? this.page,
        createdAt: createdAt ?? this.createdAt,
      );
}