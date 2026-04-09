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
      idFanfic: json['id'] as int?,
      ao3Id: json['ao3_id'] as String?,
      title: json['title'] as String?,
      author: json['author'] as String?,
      baseStory: json['source_material'] as String?,
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      genre: json['genre'] as String?,
      mainShip: json['main_ship'] as String?,
      theme: json['theme'] as String?,
      currentChapter: json['current_chapter'] as int?,
      totalChapters: json['total_chapters'] as int?,
      publicationStatus: json['publication_status'] as String?,
      tags: (json['tags'] as List?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': idFanfic,
      'ao3_id': ao3Id,
      'title': title,
      'author': author,
      'source_material': baseStory,
      'description': description,
      'cover_url': coverUrl,
      'genre': genre,
      'main_ship': mainShip,
      'theme': theme,
      'current_chapter': currentChapter,
      'total_chapters': totalChapters,
      'publication_status': publicationStatus,
      'tags': tags,
    };
  }
}
