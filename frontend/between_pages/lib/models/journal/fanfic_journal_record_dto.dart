class FanficJournalRecordDTO {
  final int userId;
  final int? fanfictionId;

  final String? ao3Id;
  final String? title;
  final String? author;
  final String? sourceMaterial;
  final String? description;
  final String? coverUrl;
  final String? genre;
  final String? theme;
  final int? totalChapters;
  final String? publicationStatus;

  final String status;
  final int? currentChapter;
  final int? rating;

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
    this.title,
    this.author,
    this.sourceMaterial,
    this.description,
    this.coverUrl,
    this.genre,
    this.theme,
    this.totalChapters,
    this.publicationStatus,
    required this.status,
    this.currentChapter,
    this.rating,
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
      title: json['title'] as String?,
      author: json['author'] as String?,
      sourceMaterial: json['source_material'] as String?,
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      genre: json['genre'] as String?,
      theme: json['theme'] as String?,
      totalChapters: json['total_chapters'] as int?,
      publicationStatus: json['publication_status'] as String?,
      status: json['status'] as String,
      currentChapter: json['current_chapter'] as int?,
      rating: json['rating'] as int?,
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

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'fanfiction_id': fanfictionId,
      'ao3_id': ao3Id,
      'title': title,
      'author': author,
      'source_material': sourceMaterial,
      'description': description,
      'cover_url': coverUrl,
      'genre': genre,
      'theme': theme,
      'total_chapters': totalChapters,
      'publication_status': publicationStatus,
      'status': status,
      'current_chapter': currentChapter,
      'rating': rating,
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
}
