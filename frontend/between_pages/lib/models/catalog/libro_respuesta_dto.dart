class LibroRespuestaDTO {
  final int idLibro;
  final String googleBooksId;
  final String titulo;
  final String autor;
  final String? isbn;
  final String? editorial;
  final String? descripcion;
  final String? portadaUrl;
  final String? genero;
  final String? tipoLibro;
  final int? anioPublicacion;

  LibroRespuestaDTO({
    required this.idLibro,
    required this.googleBooksId,
    required this.titulo,
    required this.autor,
    this.isbn,
    this.editorial,
    this.descripcion,
    this.portadaUrl,
    this.genero,
    this.tipoLibro,
    this.anioPublicacion,
  });

  factory LibroRespuestaDTO.fromJson(Map<String, dynamic> json) {
    return LibroRespuestaDTO(
      idLibro: json['idLibro'] as int,
      googleBooksId: json['googleBooksId'] as String,
      titulo: json['titulo'] as String,
      autor: json['autor'] as String,
      isbn: json['isbn'] as String?,
      editorial: json['editorial'] as String?,
      descripcion: json['descripcion'] as String?,
      portadaUrl: json['portadaUrl'] as String?,
      genero: json['genero'] as String?,
      tipoLibro: json['tipoLibro'] as String?,
      anioPublicacion: json['anioPublicacion'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idLibro': idLibro,
      'googleBooksId': googleBooksId,
      'titulo': titulo,
      'autor': autor,
      'isbn': isbn,
      'editorial': editorial,
      'descripcion': descripcion,
      'portadaUrl': portadaUrl,
      'genero': genero,
      'tipoLibro': tipoLibro,
      'anioPublicacion': anioPublicacion,
    };
  }
}
