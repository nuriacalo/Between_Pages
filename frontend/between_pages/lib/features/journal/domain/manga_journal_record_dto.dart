import 'package:json_annotation/json_annotation.dart';
import 'base_journal_record_dto.dart';

part 'manga_journal_record_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class MangaJournalRecordDTO implements BaseJournalRecordDTO {
  final int? id; // Add id field
  
  @override
  @JsonKey(readValue: _readUserId)
  final int userId;
  
  final int? mangaId;
  final int? malId;
  
  @override
  final String status;
  
  final int? currentChapter;
  final int? currentVolume;
  
  @override
  final int? rating;
  
  @override
  final int? tearDrops;
  
  @override
  final int? spiceFlames;
  
  final String? readingFormat;
  final String? favoriteCharacter;
  final String? favoriteArc;
  
  @override
  final String? personalNotes;
  
  @override
  final String? startDate;
  
  @override
  final String? endDate;
  
  @override
  final String? ownership;
  
  final String? loanedTo;
  
  @override
  final bool? rereading;

  MangaJournalRecordDTO({
    this.id, // Add id to constructor
    required this.userId,
    this.mangaId,
    this.malId,
    required this.status,
    this.currentChapter,
    this.currentVolume,
    this.rating,
    this.tearDrops,
    this.spiceFlames,
    this.readingFormat,
    this.favoriteCharacter,
    this.favoriteArc,
    this.personalNotes,
    this.startDate,
    this.endDate,
    this.ownership,
    this.loanedTo,
    this.rereading,
  });

  static Object? _readUserId(Map<dynamic, dynamic> json, String key) {
    return int.tryParse(json['userId']?.toString() ?? '0') ?? 0;
  }

  factory MangaJournalRecordDTO.fromJson(Map<String, dynamic> json) => 
      _$MangaJournalRecordDTOFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MangaJournalRecordDTOToJson(this);
}