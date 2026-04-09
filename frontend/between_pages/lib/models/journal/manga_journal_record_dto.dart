class MangaJournalRecordDTO {
  final int userId;
  final int? mangaId;

  final String? mangadexId;
  final String? source;
  final String? title;
  final String? mangaka;
  final String? demographic;
  final String? genre;
  final String? description;
  final String? coverUrl;
  final int? totalChapters;
  final int? totalVolumes;
  final String? publicationStatus;

  final String status;
  final int? currentChapter;
  final int? currentVolume;
  final int? rating;

  final String? readingFormat;

  final String? favoriteCharacter;
  final String? favoriteArc;
  final String? personalNotes;

  final String? startDate;
  final String? endDate;

  MangaJournalRecordDTO({
    required this.userId,
    this.mangaId,
    this.mangadexId,
    this.source,
    this.title,
    this.mangaka,
    this.demographic,
    this.genre,
    this.description,
    this.coverUrl,
    this.totalChapters,
    this.totalVolumes,
    this.publicationStatus,
    required this.status,
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

  factory MangaJournalRecordDTO.fromJson(Map<String, dynamic> json) {
    return MangaJournalRecordDTO(
      userId: json['user_id'] as int,
      mangaId: json['manga_id'] as int?,
      mangadexId: json['mangadex_id'] as String?,
      source: json['source'] as String?,
      title: json['title'] as String?,
      mangaka: json['mangaka'] as String?,
      demographic: json['demographic'] as String?,
      genre: json['genre'] as String?,
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      totalChapters: json['total_chapters'] as int?,
      totalVolumes: json['total_volumes'] as int?,
      publicationStatus: json['publication_status'] as String?,
      status: json['status'] as String,
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
      'user_id': userId,
      'manga_id': mangaId,
      'mangadex_id': mangadexId,
      'source': source,
      'title': title,
      'mangaka': mangaka,
      'demographic': demographic,
      'genre': genre,
      'description': description,
      'cover_url': coverUrl,
      'total_chapters': totalChapters,
      'total_volumes': totalVolumes,
      'publication_status': publicationStatus,
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
