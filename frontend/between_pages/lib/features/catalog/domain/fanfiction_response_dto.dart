import 'package:json_annotation/json_annotation.dart';

import 'media_item.dart';

part 'fanfiction_response_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class FanfictionResponseDTO implements MediaItem {
  @JsonKey(name: 'id', readValue: _readId)
  final int? idFanfic;

  @JsonKey(name: 'ao3Id')
  final String? ao3Id;

  @JsonKey(name: 'title')
  final String? _title;

  @JsonKey(name: 'author')
  final String? _author;

  @JsonKey(name: 'sourceMaterial')
  final String? sourceMaterial;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'coverUrl')
  @override
  final String? coverUrl;

  @JsonKey(defaultValue: [])
  final List<String> genres;

  @JsonKey(name: 'mainShip')
  final String? mainShip;

  @JsonKey(name: 'theme')
  final String? theme;

  @JsonKey(name: 'currentChapter')
  final int? currentChapter;

  @JsonKey(name: 'totalChapters')
  final int? totalChapters;

  @JsonKey(name: 'publicationStatus')
  final String? publicationStatus;

  @JsonKey(name: 'tags')
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
