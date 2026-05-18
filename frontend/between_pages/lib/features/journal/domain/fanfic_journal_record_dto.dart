import 'package:json_annotation/json_annotation.dart';
import 'base_journal_record_dto.dart';

part 'fanfic_journal_record_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class FanficJournalRecordDTO implements BaseJournalRecordDTO {
  final int? id; // Add id field
  
  @override
  final int userId;
  
  @JsonKey(name: 'fanficId', readValue: _readFanficId)
  final int fanficId;
  
  final String? ao3Id;
  
  @override
  final String status;
  final int? currentChapter;
  
  @override
  final int? rating;
  
  @override
  final int? tearDrops;
  
  @override
  final int? spiceFlames;
  
  final String? mainShip;
  final String? secondaryShips;
  final String? angstLevel;
  final String? shipLoyalty;
  final String? canonType;
  
  @override
  final bool? rereading;
  
  @override
  final String? personalNotes;
  
  @override
  final String? startDate;
  
  @override
  final String? endDate;

  @override
  final String? ownership;
  final String? readingFormat;
  final String? loanedTo;

  FanficJournalRecordDTO({
    this.id, // Add id to constructor
    required this.userId,
    required this.fanficId,
    this.ao3Id,
    required this.status,
    this.currentChapter,
    this.rating,
    this.tearDrops,
    this.spiceFlames,
    this.mainShip,
    this.secondaryShips,
    this.angstLevel,
    this.shipLoyalty,
    this.canonType,
    this.rereading,
    this.personalNotes,
    this.startDate,
    this.endDate,
    this.ownership,
    this.readingFormat,
    this.loanedTo,
  });

  // Este helper maneja el caso de que la API devuelva fanficId o fanfictionId
  static Object? _readFanficId(Map<dynamic, dynamic> json, String key) {
    return json['fanficId'] ?? json['fanfictionId'] ?? 0;
  }

  // Métodos generados automáticamente por json_serializable
  factory FanficJournalRecordDTO.fromJson(Map<String, dynamic> json) => 
      _$FanficJournalRecordDTOFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FanficJournalRecordDTOToJson(this);
}