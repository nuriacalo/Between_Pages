import '../catalog/manga_respuesta_dto.dart';

class MangaJournalRespuestaDTO {
  final int idMangaJournal;
  final MangaRespuestaDTO manga;
  final String? estado;
  final int? capituloActual;
  final int? volumenActual;
  final int? valoracion;
  final String? formatoLectura;
  final String? personajeFavorito;
  final String? arcoFavorito;
  final String? notaPersonal;
  final String? fechaInicio;
  final String? fechaFin;

  MangaJournalRespuestaDTO({
    required this.idMangaJournal,
    required this.manga,
    this.estado,
    this.capituloActual,
    this.volumenActual,
    this.valoracion,
    this.formatoLectura,
    this.personajeFavorito,
    this.arcoFavorito,
    this.notaPersonal,
    this.fechaInicio,
    this.fechaFin,
  });

  factory MangaJournalRespuestaDTO.fromJson(Map<String, dynamic> json) {
    return MangaJournalRespuestaDTO(
      idMangaJournal: json['idMangaJournal'] as int,
      manga: MangaRespuestaDTO.fromJson(json['manga'] as Map<String, dynamic>),
      estado: json['estado'] as String?,
      capituloActual: json['capituloActual'] as int?,
      volumenActual: json['volumenActual'] as int?,
      valoracion: json['valoracion'] as int?,
      formatoLectura: json['formatoLectura'] as String?,
      personajeFavorito: json['personajeFavorito'] as String?,
      arcoFavorito: json['arcoFavorito'] as String?,
      notaPersonal: json['notaPersonal'] as String?,
      fechaInicio: json['fechaInicio'] as String?,
      fechaFin: json['fechaFin'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMangaJournal': idMangaJournal,
      'manga': manga.toJson(),
      'estado': estado,
      'capituloActual': capituloActual,
      'volumenActual': volumenActual,
      'valoracion': valoracion,
      'formatoLectura': formatoLectura,
      'personajeFavorito': personajeFavorito,
      'arcoFavorito': arcoFavorito,
      'notaPersonal': notaPersonal,
      'fechaInicio': fechaInicio,
      'fechaFin': fechaFin,
    };
  }
}
