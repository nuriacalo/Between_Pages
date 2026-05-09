import 'base_journal_record_dto.dart';

class BookJournalRecordDTO implements BaseJournalRecordDTO {
  final int? id;
  final int userId;
  final int? bookId;
  final String? googleBooksId;
  final String status;
  final int? currentPage;
  final int? rating;
  final int? tearDrops;
  final int? spiceFlames;
  final String? readingFormat;
  final List<String>? emotions;
  final String? favoriteQuotes;
  final String? personalNotes;
  final String? startDate;
  final String? endDate;
  final String? ownership;
  final String? seriesName;
  final double? seriesOrder;
  final String? loanedTo;
  final bool? rereading; // Added rereading

  BookJournalRecordDTO({
    this.id,
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
    this.rereading, // Added rereading
  });

  factory BookJournalRecordDTO.fromJson(Map<String, dynamic> json) {
    return BookJournalRecordDTO(
      id: json['id'] as int?,
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      bookId: json['book_id'] as int?,
      googleBooksId: json['google_books_id'] as String?,
      status: json['status'] as String,
      currentPage: json['current_page'] as int?,
      rating: json['rating'] as int?,
      tearDrops: json['tear_drops'] as int?,
      spiceFlames: json['spice_flames'] as int?,
      readingFormat: json['reading_format'] as String?,
      emotions: (json['emotions'] as List?)?.cast<String>(),
      favoriteQuotes: json['favorite_quotes'] as String?,
      personalNotes: json['personal_notes'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      ownership: json['ownership'] as String?,
      seriesName: json['series_name'] as String?,
      seriesOrder: (json['series_order'] as num?)?.toDouble(),
      loanedTo: json['loaned_to'] as String?,
      rereading: json['rereading'] as bool?, // Parse rereading
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'book_id': bookId,
      'google_books_id': googleBooksId,
      'status': status,
      'current_page': currentPage,
      'rating': rating,
      'tear_drops': tearDrops,
      'spice_flames': spiceFlames,
      'reading_format': readingFormat,
      'emotions': emotions,
      'favorite_quotes': favoriteQuotes,
      'personal_notes': personalNotes,
      'start_date': startDate,
      'end_date': endDate,
      'ownership': ownership,
      'series_name': seriesName,
      'series_order': seriesOrder,
      'loaned_to': loanedTo,
      'rereading': rereading, // Add rereading to toJson
    };
  }
}
