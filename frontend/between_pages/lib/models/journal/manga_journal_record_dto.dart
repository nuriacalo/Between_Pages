class MangaJournalRecordDTO {
  final int userId;
  final int? mangaId;

  final int? malId;
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

  MangaJournalRecordDTO({
    required this.userId,
    this.mangaId,
    this.malId,
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
  });

  factory MangaJournalRecordDTO.fromJson(Map<String, dynamic> json) {
    return MangaJournalRecordDTO(
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      mangaId: json['manga_id'] as int?,
      malId: json['mal_id'] as int?,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'manga_id': mangaId,
      'mal_id': malId,
      'source': source,
      'title': title,
      'mangaka': mangaka,
      'demographic': demographic,
      'genre': genre,
      'description': description,
      'cover_url': coverUrl,
      'total_chapters': totalChapters,
      'total_volumes': totalVolumes,
      'publication_status': _normalizePublicationStatus(publicationStatus),
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
    };
  }

  String? _normalizePublicationStatus(String? status) {
    if (status == null || status.isEmpty) return null;
    final s = status.toUpperCase();
    if (s == 'FINISHED' || s == 'COMPLETED') return 'Finished';
    if (s == 'PUBLISHING' || s == 'ONGOING') return 'Publishing';
    if (s == 'ON_HIATUS' || s == 'HIATUS') return 'On Hiatus';
    if (s == 'DISCONTINUED' || s == 'CANCELLED') return 'Discontinued';
    if (s == 'NOT_YET_PUBLISHED' || s == 'UPCOMING') return 'Not yet published';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }
}
