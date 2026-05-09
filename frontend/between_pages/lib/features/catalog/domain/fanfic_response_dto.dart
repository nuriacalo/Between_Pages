class FanficResponseDTO {
  final int? idFanfic;
  final String? ao3Id;
  final String? title;
  final String? author;
  final String? sourceMaterial;
  final String? description;
  final String? coverUrl;
  final List<String> genres; // Changed from String genre to List<String> genres
  final String? mainShip;
  final String? theme;
  final int? currentChapter;
  final int? totalChapters;
  final String? publicationStatus;

  FanficResponseDTO({
    this.idFanfic,
    this.ao3Id,
    this.title,
    this.author,
    this.sourceMaterial,
    this.description,
    this.coverUrl,
    this.genres = const [], // Initialize with empty list
    this.mainShip,
    this.theme,
    this.currentChapter,
    this.totalChapters,
    this.publicationStatus,
  });

  factory FanficResponseDTO.fromJson(Map<String, dynamic> json) {
    return FanficResponseDTO(
      idFanfic: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      ao3Id: json['ao3_id'] as String?,
      title: json['title'] as String?,
      author: json['author'] as String?,
      sourceMaterial: json['source_material'] as String?,
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      genres: (json['genres'] as List<dynamic>?)?.cast<String>() ?? [],
      mainShip: json['main_ship'] as String?,
      theme: json['theme'] as String?,
      currentChapter: json['current_chapter'] as int?,
      totalChapters: json['total_chapters'] as int?,
      publicationStatus: json['publication_status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': idFanfic,
      'ao3_id': ao3Id,
      'title': title,
      'author': author,
      'source_material': sourceMaterial,
      'description': description,
      'cover_url': coverUrl,
      'genres': genres,
      'main_ship': mainShip,
      'theme': theme,
      'current_chapter': currentChapter,
      'total_chapters': totalChapters,
      'publication_status': publicationStatus,
    };
  }
}
