import 'package:between_pages/models/catalog/fanfiction_response_dto.dart';

class FanficJournalResponseDTO {
  final int id;
  final FanfictionResponseDTO fanfic;
  final String? status;
  final int? currentChapter;
  final int? rating;
  final String? mainShip;
  final String? secondaryShips;
  final String? angstLevel;
  final String? canonType;
  final bool? rereading;
  final String? personalNotes;
  final String? startDate;
  final String? endDate;

  FanficJournalResponseDTO({
    required this.id,
    required this.fanfic,
    this.status,
    this.currentChapter,
    this.rating,
    this.mainShip,
    this.secondaryShips,
    this.angstLevel,
    this.canonType,
    this.rereading,
    this.personalNotes,
    this.startDate,
    this.endDate,
  });

  factory FanficJournalResponseDTO.fromJson(Map<String, dynamic> json) {
    return FanficJournalResponseDTO(
      id: json['id'] as int,
      fanfic: FanfictionResponseDTO.fromJson(
        json['fanfic'] as Map<String, dynamic>,
      ),
      status: json['status'] as String?,
      currentChapter: json['current_chapter'] as int?,
      rating: json['rating'] as int?,
      mainShip: json['main_ship'] as String?,
      secondaryShips: json['secondary_ships'] as String?,
      angstLevel: json['angst_level'] as String?,
      canonType: json['canon_type'] as String?,
      rereading: json['rereading'] as bool?,
      personalNotes: json['personal_notes'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fanfic': fanfic.toJson(),
      'status': status,
      'current_chapter': currentChapter,
      'rating': rating,
      'main_ship': mainShip,
      'secondary_ships': secondaryShips,
      'angst_level': angstLevel,
      'canon_type': canonType,
      'rereading': rereading,
      'personal_notes': personalNotes,
      'start_date': startDate,
      'end_date': endDate,
    };
  }
}
