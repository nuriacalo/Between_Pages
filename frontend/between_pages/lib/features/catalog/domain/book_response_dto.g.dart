// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookResponseDTO _$BookResponseDTOFromJson(Map<String, dynamic> json) =>
    BookResponseDTO(
      idBook: (json['id'] as num).toInt(),
      googleBooksId: json['google_books_id'] as String?,
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      isbn: json['isbn'] as String?,
      publisher: json['publisher'] as String?,
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      bookType: json['book_type'] as String?,
      publishYear: (json['publication_year'] as num?)?.toInt(),
      pageCount: (json['page_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BookResponseDTOToJson(BookResponseDTO instance) =>
    <String, dynamic>{
      'id': instance.idBook,
      'google_books_id': instance.googleBooksId,
      'title': instance.title,
      'author': instance.author,
      'isbn': instance.isbn,
      'publisher': instance.publisher,
      'description': instance.description,
      'cover_url': instance.coverUrl,
      'genres': instance.genres,
      'book_type': instance.bookType,
      'publication_year': instance.publishYear,
      'page_count': instance.pageCount,
    };
