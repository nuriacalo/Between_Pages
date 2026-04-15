import '../catalog/manga_response_dto.dart';

class MangaJournalResponseDTO {
  final int id;
  final MangaResponseDTO? manga;
  final String? status;
  final int? currentChapter;
  final int? currentVolume;
  final int? rating;
  final String? readingFormat;
  final String? favoriteCharacter;
  final String? favoriteArc;
  final String? personalNotes;
  final String? startDate;
  final String? endDate;

  MangaJournalResponseDTO({
    required this.id,
    this.manga,
    this.status,
    this.currentChapter,
    this.currentVolume,
    this.rating,
    this.readingFormat,
    this.favoriteCharacter,
    this.favoriteArc,
    this.personalNotes,
    this.startDate,
    this.endDate,
  });

  factory MangaJournalResponseDTO.fromJson(Map<String, dynamic> json) {
    MangaResponseDTO? manga;
    final mangaJson = json['manga'];
    if (mangaJson != null && mangaJson is Map<String, dynamic>) {
      try {
        manga = MangaResponseDTO.fromJson(mangaJson);
      } catch (e) {
        manga = null;
      }
    }

    return MangaJournalResponseDTO(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      manga: manga,
      status: json['status'] as String?,
      currentChapter: json['current_chapter'] as int?,
      currentVolume: json['current_volume'] as int?,
      rating: json['rating'] as int?,
      readingFormat: json['reading_format'] as String?,
      favoriteCharacter: json['favorite_character'] as String?,
      favoriteArc: json['favorite_arc'] as String?,
      personalNotes: json['personal_notes'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'manga': manga?.toJson(),
      'status': status,
      'current_chapter': currentChapter,
      'current_volume': currentVolume,
      'rating': rating,
      'reading_format': readingFormat,
      'favorite_character': favoriteCharacter,
      'favorite_arc': favoriteArc,
      'personal_notes': personalNotes,
      'start_date': startDate,
      'end_date': endDate,
    };
  }
}
