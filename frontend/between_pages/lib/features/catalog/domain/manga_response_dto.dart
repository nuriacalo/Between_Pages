import 'package:json_annotation/json_annotation.dart';

import 'media_item.dart';

part 'manga_response_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class MangaResponseDTO implements MediaItem {
  @JsonKey(name: 'id', readValue: _readId)
  final int? idManga;

  @JsonKey(name: 'mal_id')
  final int? malId;

  @JsonKey(name: 'mal_score')
  final double? malScore;

  @JsonKey(name: 'source')
  final String? _source;

  @JsonKey(name: 'title')
  final String? _title;

  @JsonKey(name: 'author')
  final String? _author;

  @JsonKey(name: 'demographic')
  final String? _demographic;

  @JsonKey(defaultValue: [])
  final List<String> genres;

  final String? description;

  @JsonKey(name: 'cover_url')
  @override
  final String? coverUrl;

  @JsonKey(name: 'total_chapters')
  final int? totalChapters;

  @JsonKey(name: 'total_volumes')
  final int? totalVolumes;

  /// Legacy alias used by some widgets.
  int? get volumes => totalVolumes;


  @JsonKey(name: 'publication_status')
  final String? _publicationStatus;

  MangaResponseDTO({
    this.idManga,
    this.malId,
    this.malScore,
    String? source,
    String? title,
    String? author,
    String? demographic,
    this.genres = const [],
    this.description,
    this.coverUrl,
    this.totalChapters,
    this.totalVolumes,
    String? publicationStatus,
  })  : _source = source,
        _title = title,
        _author = author,
        _demographic = demographic,
        _publicationStatus = publicationStatus;

  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    return json['id'] != null ? int.tryParse(json['id'].toString()) : null;
  }

  factory MangaResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$MangaResponseDTOFromJson(json);

  Map<String, dynamic> toJson() => _$MangaResponseDTOToJson(this);

  @override
  MediaType get itemType => MediaType.manga;

  @override
  String get title => _title ?? 'No Title';

  @override
  String get author => _author ?? 'Unknown Author';

  String get source => _source ?? 'Unknown';
  String get demographic => _demographic ?? 'N/A';
  String get publicationStatus => _publicationStatus ?? 'Unknown';

  @override
  String? get coverImageUrl => coverUrl;
}