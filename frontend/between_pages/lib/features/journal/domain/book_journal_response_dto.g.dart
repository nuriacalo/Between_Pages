// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_journal_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookJournalResponseDto _$BookJournalResponseDtoFromJson(
  Map<String, dynamic> json,
) => BookJournalResponseDto(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  book: BookResponseDTO.fromJson(json['book'] as Map<String, dynamic>),
  status: json['status'] as String,
  currentPage: (json['currentPage'] as num?)?.toInt(),
  rating: (json['rating'] as num?)?.toInt(),
  tearDrops: (json['tearDrops'] as num?)?.toInt(),
  spiceFlames: (json['spiceFlames'] as num?)?.toInt(),
  readingFormat: json['readingFormat'] as String?,
  emotions: (json['emotions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  favoriteQuotes: json['favoriteQuotes'] as String?,
  personalNotes: json['personalNotes'] as String?,
  startDate: json['startDate'] as String?,
  endDate: json['endDate'] as String?,
  rereading: json['rereading'] as bool?,
  ownership: json['ownership'] as String?,
  seriesName: json['seriesName'] as String?,
  seriesOrder: (json['seriesOrder'] as num?)?.toDouble(),
  loanedTo: json['loanedTo'] as String?,
);

Map<String, dynamic> _$BookJournalResponseDtoToJson(
  BookJournalResponseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'status': instance.status,
  'personalNotes': instance.personalNotes,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
  'rating': instance.rating,
  'tearDrops': instance.tearDrops,
  'spiceFlames': instance.spiceFlames,
  'rereading': instance.rereading,
  'ownership': instance.ownership,
  'readingFormat': instance.readingFormat,
  'loanedTo': instance.loanedTo,
  'book': instance.book.toJson(),
  'currentPage': instance.currentPage,
  'emotions': instance.emotions,
  'favoriteQuotes': instance.favoriteQuotes,
  'seriesName': instance.seriesName,
  'seriesOrder': instance.seriesOrder,
};
