class BookJournalRecordDTO {
  final int userId;
  final int? bookId;

  final String? googleBooksId;
  final String? title;
  final String? author;
  final String? isbn;
  final String? publisher;
  final String? description;
  final String? coverUrl;
  final String? genre;
  final String? bookType;
  final int? publicationYear;

  final String status;
  final int? currentPage;
  final int? rating;
  final String? readingFormat;

  final List<String>? emotions;
  final String? favoriteQuotes;
  final String? personalNotes;

  final String? startDate;
  final String? endDate;

  BookJournalRecordDTO({
    required this.userId,
    this.bookId,
    this.googleBooksId,
    this.title,
    this.author,
    this.isbn,
    this.publisher,
    this.description,
    this.coverUrl,
    this.genre,
    this.bookType,
    this.publicationYear,
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

  factory BookJournalRecordDTO.fromJson(Map<String, dynamic> json) {
    return BookJournalRecordDTO(
      userId: json['user_id'] as int,
      bookId: json['book_id'] as int?,
      googleBooksId: json['google_books_id'] as String?,
      title: json['title'] as String?,
      author: json['author'] as String?,
      isbn: json['isbn'] as String?,
      publisher: json['publisher'] as String?,
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      genre: json['genre'] as String?,
      bookType: json['book_type'] as String?,
      publicationYear: json['publication_year'] as int?,
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
      'user_id': userId,
      'book_id': bookId,
      'google_books_id': googleBooksId,
      'title': title,
      'author': author,
      'isbn': isbn,
      'publisher': publisher,
      'description': description,
      'cover_url': coverUrl,
      'genre': genre,
      'book_type': bookType,
      'publication_year': publicationYear,
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
