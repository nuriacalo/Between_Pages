class MangaResponseDTO {
  final int? idManga;
  final int? malId;
  final double? malScore;
  final String? source;
  final String? title;
  final String? author;
  final String? demographic;
  final List<String> genres;
  final String? description;
  final String? coverUrl;
  final int? totalChapters;
  final int? totalVolumes;
  final String? publicationStatus;

  MangaResponseDTO({
    this.idManga,
    this.malId,
    this.malScore,
    this.source,
    this.title,
    this.author,
    this.demographic,
    this.genres = const [],
    this.description,
    this.coverUrl,
    this.totalChapters,
    this.totalVolumes,
    this.publicationStatus,
  });

  factory MangaResponseDTO.fromJson(Map<String, dynamic> json) {
    return MangaResponseDTO(
      idManga: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      malId: json['mal_id'] as int?,
      malScore: (json['mal_score'] as num?)?.toDouble(),
      source: json['source'] as String?,
      title: json['title'] as String?,
      author: json['author'] as String?,
      demographic: json['demographic'] as String?,
      genres: (json['genres'] as List<dynamic>?)?.cast<String>() ?? [],
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      totalChapters: json['total_chapters'] as int?,
      totalVolumes: json['total_volumes'] as int?,
      publicationStatus: json['publication_status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': idManga,
      'mal_id': malId,
      'mal_score': malScore,
      'source': source,
      'title': title,
      'author': author,
      'demographic': demographic,
      'genres': genres,
      'description': description,
      'cover_url': coverUrl,
      'total_chapters': totalChapters,
      'total_volumes': totalVolumes,
      'publication_status': publicationStatus,
    };
  }
}
