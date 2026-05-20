// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_journal_record_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookJournalRecordDTO _$BookJournalRecordDTOFromJson(
  Map<String, dynamic> json,
) => BookJournalRecordDTO(
  id: (json['id'] as num?)?.toInt(),
  userId: (BookJournalRecordDTO._readUserId(json, 'userId') as num).toInt(),
  bookId: (json['bookId'] as num?)?.toInt(),
  googleBooksId: json['googleBooksId'] as String?,
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
  ownership: json['ownership'] as String?,
  seriesName: json['seriesName'] as String?,
  seriesOrder: (json['seriesOrder'] as num?)?.toDouble(),
  loanedTo: json['loanedTo'] as String?,
  rereading: json['rereading'] as bool?,
);

Map<String, dynamic> _$BookJournalRecordDTOToJson(
  BookJournalRecordDTO instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'userId': instance.userId,
  'bookId': ?instance.bookId,
  'googleBooksId': ?instance.googleBooksId,
  'status': instance.status,
  'currentPage': ?instance.currentPage,
  'rating': ?instance.rating,
  'tearDrops': ?instance.tearDrops,
  'spiceFlames': ?instance.spiceFlames,
  'readingFormat': ?instance.readingFormat,
  'emotions': ?instance.emotions,
  'favoriteQuotes': ?instance.favoriteQuotes,
  'personalNotes': ?instance.personalNotes,
  'startDate': ?instance.startDate,
  'endDate': ?instance.endDate,
  'ownership': ?instance.ownership,
  'seriesName': ?instance.seriesName,
  'seriesOrder': ?instance.seriesOrder,
  'loanedTo': ?instance.loanedTo,
  'rereading': ?instance.rereading,
};
