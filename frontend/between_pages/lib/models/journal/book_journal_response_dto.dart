import '../catalog/book_response_dto.dart';

class BookJournalResponseDto {
  final int id;
  final BookResponseDTO book;
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
  final bool? rereading;
  final String? ownership;
  final String? seriesName;
  final double? seriesOrder;
  final String? loanedTo;

  BookJournalResponseDto({
    required this.id,
    required this.book,
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
    this.rereading,
    this.ownership,
    this.seriesName,
    this.seriesOrder,
    this.loanedTo,
  });

  factory BookJournalResponseDto.fromJson(Map<String, dynamic> json) {
    return BookJournalResponseDto(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      book: BookResponseDTO.fromJson(json['book'] as Map<String, dynamic>),
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
      rereading: json['rereading'] as bool?,
      ownership: json['ownership'] as String?,
      seriesName: json['series_name'] as String?,
      seriesOrder: (json['series_order'] as num?)?.toDouble(),
      loanedTo: json['loaned_to'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book': book.toJson(),
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
      'rereading': rereading,
      'ownership': ownership,
      'series_name': seriesName,
      'series_order': seriesOrder,
      'loaned_to': loanedTo,
    };
  }
}
