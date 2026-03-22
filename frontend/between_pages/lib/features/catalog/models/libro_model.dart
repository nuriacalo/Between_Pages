// lib/features/catalog/models/libro_model.dart
class LibroModel {
  final int? idLibro;
  final String? googleBooksId;
  final String titulo;
  final String autor;
  final String? isbn;
  final String? editorial;
  final String? descripcion;
  final String? portadaUrl;
  final String? genero;
  final String? tipoLibro;
  final int? anioPublicacion;

  LibroModel({
    this.idLibro,
    this.googleBooksId,
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

  factory LibroModel.fromJson(Map<String, dynamic> json) {
    return LibroModel(
      idLibro: json['idLibro'],
      googleBooksId: json['googleBooksId'],
      titulo: json['titulo'] ?? 'Sin título',
      autor: json['autor'] ?? 'Autor desconocido',
      isbn: json['isbn'],
      editorial: json['editorial'],
      descripcion: json['descripcion'],
      portadaUrl: json['portadaUrl'],
      genero: json['genero'],
      tipoLibro: json['tipoLibro'],
      anioPublicacion: json['anioPublicacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
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