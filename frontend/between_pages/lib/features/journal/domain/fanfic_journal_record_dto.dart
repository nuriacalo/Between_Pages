import 'base_journal_record_dto.dart';

class FanficJournalRecordDTO implements BaseJournalRecordDTO {
  final int userId;
  final int? fanfictionId;
  final String? ao3Id;
  final String status;
  final int? currentChapter;
  final int? rating;
  final int? tearDrops;
  final int? spiceFlames;
  final String? mainShip;
  final String? secondaryShips;
  final String? angstLevel;
  final String? shipLoyalty;
  final String? canonType;
  final bool? rereading;
  final String? personalNotes;
  final String? startDate;
  final String? endDate;

  FanficJournalRecordDTO({
    required this.userId,
    this.fanfictionId,
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
  });

  factory FanficJournalRecordDTO.fromJson(Map<String, dynamic> json) {
    return FanficJournalRecordDTO(
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      fanfictionId: json['fanfiction_id'] as int?,
      ao3Id: json['ao3_id'] as String?,
      status: json['status'] as String,
      currentChapter: json['current_chapter'] as int?,
      rating: json['rating'] as int?,
      tearDrops: json['tear_drops'] as int?,
      spiceFlames: json['spice_flames'] as int?,
      mainShip: json['main_ship'] as String?,
      secondaryShips: json['secondary_ships'] as String?,
      angstLevel: json['angst_level'] as String?,
      shipLoyalty: json['ship_loyalty'] as String?,
      canonType: json['canon_type'] as String?,
      rereading: json['rereading'] as bool?,
      personalNotes: json['personal_notes'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'fanfiction_id': fanfictionId,
      'ao3_id': ao3Id,
      'status': status,
      'current_chapter': currentChapter,
      'rating': rating,
      'tear_drops': tearDrops,
      'spice_flames': spiceFlames,
      'main_ship': mainShip,
      'secondary_ships': secondaryShips,
      'angst_level': angstLevel,
      'ship_loyalty': shipLoyalty,
      'canon_type': canonType,
      'rereading': rereading,
      'personal_notes': personalNotes,
      'start_date': startDate,
      'end_date': endDate,
    };
  }

  @override
  String? get ownership => null;
}
