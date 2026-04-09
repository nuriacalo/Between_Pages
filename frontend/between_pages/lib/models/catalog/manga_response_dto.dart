class MangaResponseDTO {
  final int? idManga;
  final String? mangadexId;
  final String? title;
  final String? mangaka;
  final String? demographic;
  final String? genre;
  final String? description;
  final String? coverUrl;
  final int? totalChapters;
  final int? totalVolumes;
  final String? publicationStatus;

  MangaResponseDTO({
    this.idManga,
    this.mangadexId,
    this.title,
    this.mangaka,
    this.demographic,
    this.genre,
    this.description,
    this.coverUrl,
    this.totalChapters,
    this.totalVolumes,
    this.publicationStatus,
  });

  factory MangaResponseDTO.fromJson(Map<String, dynamic> json) {
    return MangaResponseDTO(
      idManga: json['id'] as int?,
      mangadexId: json['mangadex_id'] as String?,
      title: json['title'] as String?,
      mangaka: json['author'] as String?,
      demographic: json['demographic'] as String?,
      genre: json['genre'] as String?,
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
      'mangadex_id': mangadexId,
      'title': title,
      'author': mangaka,
      'demographic': demographic,
      'genre': genre,
      'description': description,
      'cover_url': coverUrl,
      'total_chapters': totalChapters,
      'total_volumes': totalVolumes,
      'publication_status': publicationStatus,
    };
  }
}
