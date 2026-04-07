class MangaJournalRecordDTO {
  final int idUsuario;
  final int? idManga;

  final String? mangadexId;
  final String? fuente;
  final String? titulo;
  final String? mangaka;
  final String? demografia;
  final String? genero;
  final String? descripcion;
  final String? portadaUrl;
  final int? totalCapitulos;
  final int? totalVolumenes;
  final String? estadoPublicacion;

  final String estado;
  final int? capituloActual;
  final int? volumenActual;
  final int? valoracion;

  final String? formatoLectura;

  final String? personajeFavorito;
  final String? arcoFavorito;
  final String? notaPersonal;

  final String? fechaInicio;
  final String? fechaFin;

  MangaJournalRecordDTO({
    required this.idUsuario,
    this.idManga,
    this.mangadexId,
    this.fuente,
    this.titulo,
    this.mangaka,
    this.demografia,
    this.genero,
    this.descripcion,
    this.portadaUrl,
    this.totalCapitulos,
    this.totalVolumenes,
    this.estadoPublicacion,
    required this.estado,
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

  factory MangaJournalRecordDTO.fromJson(Map<String, dynamic> json) {
    return MangaJournalRecordDTO(
      idUsuario: json['idUsuario'] as int,
      idManga: json['idManga'] as int?,
      mangadexId: json['mangadexId'] as String?,
      fuente: json['fuente'] as String?,
      titulo: json['titulo'] as String?,
      mangaka: json['mangaka'] as String?,
      demografia: json['demografia'] as String?,
      genero: json['genero'] as String?,
      descripcion: json['descripcion'] as String?,
      portadaUrl: json['portadaUrl'] as String?,
      totalCapitulos: json['totalCapitulos'] as int?,
      totalVolumenes: json['totalVolumenes'] as int?,
      estadoPublicacion: json['estadoPublicacion'] as String?,
      estado: json['estado'] as String,
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
      'idUsuario': idUsuario,
      'idManga': idManga,
      'mangadexId': mangadexId,
      'fuente': fuente,
      'titulo': titulo,
      'mangaka': mangaka,
      'demografia': demografia,
      'genero': genero,
      'descripcion': descripcion,
      'portadaUrl': portadaUrl,
      'totalCapitulos': totalCapitulos,
      'totalVolumenes': totalVolumenes,
      'estadoPublicacion': estadoPublicacion,
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
