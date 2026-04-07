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
      idManga: json['idManga'] as int?,
      mangadexId: json['mangadexId'] as String?,
      title: json['titulo'] as String?,
      mangaka: json['mangaka'] as String?,
      demographic: json['demografia'] as String?,
      genre: json['genero'] as String?,
      description: json['descripcion'] as String?,
      coverUrl: json['portadaUrl'] as String?,
      totalChapters: json['totalCapitulos'] as int?,
      totalVolumes: json['totalVolumenes'] as int?,
      publicationStatus: json['estadoPublicacion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idManga': idManga,
      'mangadexId': mangadexId,
      'titulo': title,
      'mangaka': mangaka,
      'demografia': demographic,
      'genero': genre,
      'descripcion': description,
      'portadaUrl': coverUrl,
      'totalCapitulos': totalChapters,
      'totalVolumenes': totalVolumes,
      'estadoPublicacion': publicationStatus,
    };
  }
}
