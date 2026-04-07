class FanfictionResponseDTO {
  final int? idFanfic;
  final String? ao3Id;
  final String? title;
  final String? author;
  final String? baseStory;
  final String? description;
  final String? coverUrl;
  final String? genre;
  final String? mainShip;
  final String? theme;
  final int? currentChapter;
  final int? totalChapters;
  final String? publicationStatus;
  final List<String>? tags;

  FanfictionResponseDTO({
    this.idFanfic,
    this.ao3Id,
    this.title,
    this.author,
    this.baseStory,
    this.description,
    this.coverUrl,
    this.genre,
    this.mainShip,
    this.theme,
    this.currentChapter,
    this.totalChapters,
    this.publicationStatus,
    this.tags,
  });

  factory FanfictionResponseDTO.fromJson(Map<String, dynamic> json) {
    return FanfictionResponseDTO(
      idFanfic: json['idFanfic'] as int?,
      ao3Id: json['ao3Id'] as String?,
      title: json['titulo'] as String?,
      author: json['autor'] as String?,
      baseStory: json['historiaBase'] as String?,
      description: json['descripcion'] as String?,
      coverUrl: json['portadaUrl'] as String?,
      genre: json['genero'] as String?,
      mainShip: json['shipPrincipal'] as String?,
      theme: json['tematica'] as String?,
      currentChapter: json['capituloActual'] as int?,
      totalChapters: json['totalCapitulos'] as int?,
      publicationStatus: json['estadoPublicacion'] as String?,
      tags: (json['tags'] as List?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idFanfic': idFanfic,
      'ao3Id': ao3Id,
      'titulo': title,
      'autor': author,
      'historiaBase': baseStory,
      'descripcion': description,
      'portadaUrl': coverUrl,
      'genero': genre,
      'shipPrincipal': mainShip,
      'tematica': theme,
      'capituloActual': currentChapter,
      'totalCapitulos': totalChapters,
      'estadoPublicacion': publicationStatus,
      'tags': tags,
    };
  }
}
