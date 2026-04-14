class BookResponseDTO {
  final int idBook;
  final String googleBooksId;
  final String title;
  final String author;
  final String? isbn;
  final String? publisher;
  final String? description;
  final String? coverUrl;
  final String? genre;
  final String? bookType;
  final int? publishYear;

  BookResponseDTO({
    required this.idBook,
    required this.googleBooksId,
    required this.title,
    required this.author,
    this.isbn,
    this.publisher,
    this.description,
    this.coverUrl,
    this.genre,
    this.bookType,
    this.publishYear,
  });

  factory BookResponseDTO.fromJson(Map<String, dynamic> json) {
    return BookResponseDTO(
      idBook: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      googleBooksId: json['google_books_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      isbn: json['isbn'] as String?,
      publisher: json['publisher'] as String?,
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      genre: json['genre'] as String?,
      bookType: json['book_type'] as String?,
      publishYear: json['publication_year'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': idBook,
      'google_books_id': googleBooksId,
      'title': title,
      'author': author,
      'isbn': isbn,
      'publisher': publisher,
      'description': description,
      'cover_url': coverUrl,
      'genre': genre,
      'book_type': bookType,
      'publication_year': publishYear,
    };
  }
}
