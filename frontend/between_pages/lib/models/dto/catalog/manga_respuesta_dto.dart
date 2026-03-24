class MangaRespuestaDTO {
  final int? idManga;
  final String? mangadexId;
  final String? titulo;
  final String? mangaka;
  final String? demografia;
  final String? genero;
  final String? descripcion;
  final String? portadaUrl;
  final int? totalCapitulos;
  final int? totalVolumenes;
  final String? estadoPublicacion;

  MangaRespuestaDTO({
    this.idManga,
    this.mangadexId,
    this.titulo,
    this.mangaka,
    this.demografia,
    this.genero,
    this.descripcion,
    this.portadaUrl,
    this.totalCapitulos,
    this.totalVolumenes,
    this.estadoPublicacion,
  });

  factory MangaRespuestaDTO.fromJson(Map<String, dynamic> json) {
    return MangaRespuestaDTO(
      idManga: json['idManga'] as int?,
      mangadexId: json['mangadexId'] as String?,
      titulo: json['titulo'] as String?,
      mangaka: json['mangaka'] as String?,
      demografia: json['demografia'] as String?,
      genero: json['genero'] as String?,
      descripcion: json['descripcion'] as String?,
      portadaUrl: json['portadaUrl'] as String?,
      totalCapitulos: json['totalCapitulos'] as int?,
      totalVolumenes: json['totalVolumenes'] as int?,
      estadoPublicacion: json['estadoPublicacion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idManga': idManga,
      'mangadexId': mangadexId,
      'titulo': titulo,
      'mangaka': mangaka,
      'demografia': demografia,
      'genero': genero,
      'descripcion': descripcion,
      'portadaUrl': portadaUrl,
      'totalCapitulos': totalCapitulos,
      'totalVolumenes': totalVolumenes,
      'estadoPublicacion': estadoPublicacion,
    };
  }
}
