import 'base_journal_record_dto.dart';

class MangaJournalRecordDTO implements BaseJournalRecordDTO {
  final int userId;
  final int? mangaId;
  final int? malId;
  final String status;
  final int? currentChapter;
  final int? currentVolume;
  final int? rating;
  final int? tearDrops;
  final int? spiceFlames;
  final String? readingFormat;
  final String? favoriteCharacter;
  final String? favoriteArc;
  final String? personalNotes;
  final String? startDate;
  final String? endDate;
  final String? ownership;
  final String? loanedTo;
  final bool? rereading; // Added rereading

  MangaJournalRecordDTO({
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
    this.rereading, // Added rereading
  });

  factory MangaJournalRecordDTO.fromJson(Map<String, dynamic> json) {
    return MangaJournalRecordDTO(
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      mangaId: json['manga_id'] as int?,
      malId: json['mal_id'] as int?,
      status: json['status'] as String,
      currentChapter: json['current_chapter'] as int?,
      currentVolume: json['current_volume'] as int?,
      rating: json['rating'] as int?,
      tearDrops: json['tear_drops'] as int?,
      spiceFlames: json['spice_flames'] as int?,
      readingFormat: json['reading_format'] as String?,
      favoriteCharacter: json['favorite_character'] as String?,
      favoriteArc: json['favorite_arc'] as String?,
      personalNotes: json['personal_notes'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      ownership: json['ownership'] as String?,
      loanedTo: json['loaned_to'] as String?,
      rereading: json['rereading'] as bool?, // Parse rereading
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'manga_id': mangaId,
      'mal_id': malId,
      'status': status,
      'current_chapter': currentChapter,
      'current_volume': currentVolume,
      'rating': rating,
      'tear_drops': tearDrops,
      'spice_flames': spiceFlames,
      'reading_format': readingFormat,
      'favorite_character': favoriteCharacter,
      'favorite_arc': favoriteArc,
      'personal_notes': personalNotes,
      'start_date': startDate,
      'end_date': endDate,
      'ownership': ownership,
      'loaned_to': loanedTo,
      'rereading': rereading, // Add rereading to toJson
    };
  }
}
