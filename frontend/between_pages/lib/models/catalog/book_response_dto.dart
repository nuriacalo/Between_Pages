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
      idBook: json['idLibro'] as int,
      googleBooksId: json['googleBooksId'] as String,
      title: json['titulo'] as String,
      author: json['autor'] as String,
      isbn: json['isbn'] as String?,
      publisher: json['editorial'] as String?,
      description: json['descripcion'] as String?,
      coverUrl: json['portadaUrl'] as String?,
      genre: json['genero'] as String?,
      bookType: json['tipoLibro'] as String?,
      publishYear: json['anioPublicacion'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idLibro': idBook,
      'googleBooksId': googleBooksId,
      'titulo': title,
      'autor': author,
      'isbn': isbn,
      'editorial': publisher,
      'descripcion': description,
      'portadaUrl': coverUrl,
      'genero': genre,
      'tipoLibro': bookType,
      'anioPublicacion': publishYear,
    };
  }
}
