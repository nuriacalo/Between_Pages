import 'package:json_annotation/json_annotation.dart';

part 'reading_session_record_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class ReadingSessionRecordDTO {
  final int userId;
  final int? bookId;
  final int? mangaId;
  final int? fanficId;
  final int durationSeconds;
  final int pagesRead;

  ReadingSessionRecordDTO({
    required this.userId,
    this.bookId,
    this.mangaId,
    this.fanficId,
    required this.durationSeconds,
    required this.pagesRead,
  });

  factory ReadingSessionRecordDTO.fromJson(Map<String, dynamic> json) => 
      _$ReadingSessionRecordDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingSessionRecordDTOToJson(this);
}
