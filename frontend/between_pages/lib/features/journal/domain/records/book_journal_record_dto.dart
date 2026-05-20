import 'package:json_annotation/json_annotation.dart';
import 'base_journal_record_dto.dart';

part 'book_journal_record_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class BookJournalRecordDTO implements BaseJournalRecordDTO {
  final int? id; // Add id field
  
  @override
  @JsonKey(readValue: _readUserId)
  final int userId;
  
  final int? bookId;
  final String? googleBooksId;
  
  @override
  final String status;
  
  final int? currentPage;
  
  @override
  final int? rating;
  
  @override
  final int? tearDrops;
  
  @override
  final int? spiceFlames;
  
  final String? readingFormat;
  final List<String>? emotions;
  final String? favoriteQuotes;
  
  @override
  final String? personalNotes;
  
  @override
  final String? startDate;
  
  @override
  final String? endDate;
  
  @override
  final String? ownership;
  
  final String? seriesName;
  final double? seriesOrder;
  final String? loanedTo;
  
  @override
  final bool? rereading;

  BookJournalRecordDTO({
    this.id, // Add id to constructor
    required this.userId,
    this.bookId,
    this.googleBooksId,
    required this.status,
    this.currentPage,
    this.rating,
    this.tearDrops,
    this.spiceFlames,
    this.readingFormat,
    this.emotions,
    this.favoriteQuotes,
    this.personalNotes,
    this.startDate,
    this.endDate,
    this.ownership,
    this.seriesName,
    this.seriesOrder,
    this.loanedTo,
    this.rereading,
  });

  static Object? _readUserId(Map<dynamic, dynamic> json, String key) {
    return int.tryParse(json['userId']?.toString() ?? '0') ?? 0;
  }

  factory BookJournalRecordDTO.fromJson(Map<String, dynamic> json) => 
      _$BookJournalRecordDTOFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BookJournalRecordDTOToJson(this);
}