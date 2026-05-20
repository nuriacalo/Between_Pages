import 'package:json_annotation/json_annotation.dart';
import 'media_item.dart';

part 'book_response_dto.g.dart';

@JsonSerializable()
class BookResponseDTO implements MediaItem {
  @JsonKey(name: 'id', defaultValue: 0)
  final int? idBook;

  @JsonKey(name: 'google_books_id')
  final String? googleBooksId;

  @override
  final String title;

  @override
  final String author;

  final String? isbn;
  final String? publisher;
  final String? description;

  @JsonKey(name: 'cover_url')
  final String? coverUrl;

  final List<String> genres;

  @JsonKey(name: 'book_type')
  final String? bookType;

  @JsonKey(name: 'publication_year')
  final int? publishYear;

  @JsonKey(name: 'page_count')
  final int? pageCount;

  BookResponseDTO({
    this.idBook,
    this.googleBooksId,
    this.title = '',
    this.author = '',
    this.isbn,
    this.publisher,
    this.description,
    this.coverUrl,
    this.genres = const [],
    this.bookType,
    this.publishYear,
    this.pageCount,
  });

  factory BookResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$BookResponseDTOFromJson(json);

  Map<String, dynamic> toJson() => _$BookResponseDTOToJson(this);

  @override
  MediaType get itemType => MediaType.book;

  @override
  String? get coverImageUrl => coverUrl;
}