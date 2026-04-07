import '../catalog/book_response_dto.dart';

class BookJournalResponseDto {
  final int idLibroJournal;
  final BookResponseDTO libro;
  final String estado;
  final int? paginaActual;
  final int? valoracion;
  final String? formatoLectura;
  final List<String>? emociones;
  final String? citasFavoritas;
  final String? notaPersonal;
  final String? fechaInicio;
  final String? fechaFin;

  BookJournalResponseDto({
    required this.idLibroJournal,
    required this.libro,
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

  factory BookJournalResponseDto.fromJson(Map<String, dynamic> json) {
    return BookJournalResponseDto(
      idLibroJournal: json['idLibroJournal'] as int,
      libro: BookResponseDTO.fromJson(json['libro'] as Map<String, dynamic>),
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
      'idLibroJournal': idLibroJournal,
      'libro': libro.toJson(),
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
