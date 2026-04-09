import '../catalog/book_response_dto.dart';

class BookJournalResponseDto {
  final int id;
  final BookResponseDTO book;
  final String status;
  final int? currentPage;
  final int? rating;
  final String? readingFormat;
  final List<String>? emotions;
  final String? favoriteQuotes;
  final String? personalNotes;
  final String? startDate;
  final String? endDate;

  BookJournalResponseDto({
    required this.id,
    required this.book,
    required this.status,
    this.currentPage,
    this.rating,
    this.readingFormat,
    this.emotions,
    this.favoriteQuotes,
    this.personalNotes,
    this.startDate,
    this.endDate,
  });

  factory BookJournalResponseDto.fromJson(Map<String, dynamic> json) {
    return BookJournalResponseDto(
      id: json['id'] as int,
      book: BookResponseDTO.fromJson(json['book'] as Map<String, dynamic>),
      status: json['status'] as String,
      currentPage: json['current_page'] as int?,
      rating: json['rating'] as int?,
      readingFormat: json['reading_format'] as String?,
      emotions: (json['emotions'] as List?)?.cast<String>(),
      favoriteQuotes: json['favorite_quotes'] as String?,
      personalNotes: json['personal_notes'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book': book.toJson(),
      'status': status,
      'current_page': currentPage,
      'rating': rating,
      'reading_format': readingFormat,
      'emotions': emotions,
      'favorite_quotes': favoriteQuotes,
      'personal_notes': personalNotes,
      'start_date': startDate,
      'end_date': endDate,
    };
  }
}
