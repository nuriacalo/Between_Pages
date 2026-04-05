class LibroJournalRegistroDTO {
  final int idUsuario;
  final int? idLibro;

  final String? googleBooksId;
  final String? titulo;
  final String? autor;
  final String? isbn;
  final String? editorial;
  final String? descripcion;
  final String? portadaUrl;
  final String? genero;
  final String? tipoLibro;
  final int? anioPublicacion;

  final String estado;
  final int? paginaActual;
  final int? valoracion;
  final String? formatoLectura;

  final List<String>? emociones;
  final String? citasFavoritas;
  final String? notaPersonal;

  final String? fechaInicio;
  final String? fechaFin;

  LibroJournalRegistroDTO({
    required this.idUsuario,
    this.idLibro,
    this.googleBooksId,
    this.titulo,
    this.autor,
    this.isbn,
    this.editorial,
    this.descripcion,
    this.portadaUrl,
    this.genero,
    this.tipoLibro,
    this.anioPublicacion,
    required this.estado,
    this.paginaActual,
    this.valoracion,
    this.formatoLectura,
    this.emociones,
    this.citasFavoritas,
    this.notaPersonal,
    this.fechaInicio,
    this.fechaFin,
  });

  factory LibroJournalRegistroDTO.fromJson(Map<String, dynamic> json) {
    return LibroJournalRegistroDTO(
      idUsuario: json['idUsuario'] as int,
      idLibro: json['idLibro'] as int?,
      googleBooksId: json['googleBooksId'] as String?,
      titulo: json['titulo'] as String?,
      autor: json['autor'] as String?,
      isbn: json['isbn'] as String?,
      editorial: json['editorial'] as String?,
      descripcion: json['descripcion'] as String?,
      portadaUrl: json['portadaUrl'] as String?,
      genero: json['genero'] as String?,
      tipoLibro: json['tipoLibro'] as String?,
      anioPublicacion: json['anioPublicacion'] as int?,
      estado: json['estado'] as String,
      paginaActual: json['paginaActual'] as int?,
      valoracion: json['valoracion'] as int?,
      formatoLectura: json['formatoLectura'] as String?,
      emociones: (json['emociones'] as List?)?.cast<String>(),
      citasFavoritas: json['citasFavoritas'] as String?,
      notaPersonal: json['notaPersonal'] as String?,
      fechaInicio: json['fechaInicio'] as String?,
      fechaFin: json['fechaFin'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
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
      'estado': estado,
      'paginaActual': paginaActual,
      'valoracion': valoracion,
      'formatoLectura': formatoLectura,
      'emociones': emociones,
      'citasFavoritas': citasFavoritas,
      'notaPersonal': notaPersonal,
      'fechaInicio': fechaInicio,
      'fechaFin': fechaFin,
    };
  }
}
