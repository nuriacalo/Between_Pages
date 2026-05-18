import 'package:json_annotation/json_annotation.dart';

import 'media_item.dart';

part 'fanfiction_response_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class FanfictionResponseDTO implements MediaItem {
  @JsonKey(name: 'id', readValue: _readId)
  final int? idFanfic;

  @JsonKey(name: 'ao3_id')
  final String? ao3Id;

  @JsonKey(name: 'title')
  final String? _title;

  @JsonKey(name: 'author')
  final String? _author;

  @JsonKey(name: 'source_material')
  final String? sourceMaterial;

  final String? description;

  @JsonKey(name: 'cover_url')
  @override
  final String? coverUrl;

  @JsonKey(defaultValue: [])
  final List<String> genres;

  @JsonKey(name: 'main_ship')
  final String? mainShip;

  final String? theme;

  @JsonKey(name: 'current_chapter')
  final int? currentChapter;

  @JsonKey(name: 'total_chapters')
  final int? totalChapters;

  @JsonKey(name: 'publication_status')
  final String? publicationStatus;

  final List<String>? tags;

  /// Legacy alias used by some widgets.
  int? get angstLevel => null;


  FanfictionResponseDTO({
    this.idFanfic,
    this.ao3Id,
    String? title,
    String? author,
    this.sourceMaterial,
    this.description,
    this.coverUrl,
    this.genres = const [],
    this.mainShip,
    this.theme,
    this.currentChapter,
    this.totalChapters,
    this.publicationStatus,
    this.tags,
  })  : _title = title,
        _author = author;

  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    return int.tryParse(json['id']?.toString() ?? '0');
  }

  factory FanfictionResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$FanfictionResponseDTOFromJson(json);

  Map<String, dynamic> toJson() =>
      _$FanfictionResponseDTOToJson(this);

  @override
  MediaType get itemType => MediaType.fanfic;

  @override
  String get title => _title ?? 'No Title';

  @override
  String get author => _author ?? 'Unknown Author';

  @override
  String? get coverImageUrl => coverUrl;
}

