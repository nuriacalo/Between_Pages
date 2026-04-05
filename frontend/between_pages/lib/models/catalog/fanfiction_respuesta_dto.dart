class FanfictionRespuestaDTO {
  final int? idFanfic;
  final String? ao3Id;
  final String? titulo;
  final String? autor;
  final String? historiaBase;
  final String? descripcion;
  final String? portadaUrl;
  final String? genero;
  final String? shipPrincipal;
  final String? tematica;
  final int? capituloActual;
  final int? totalCapitulos;
  final String? estadoPublicacion;
  final List<String>? tags;

  FanfictionRespuestaDTO({
    this.idFanfic,
    this.ao3Id,
    this.titulo,
    this.autor,
    this.historiaBase,
    this.descripcion,
    this.portadaUrl,
    this.genero,
    this.shipPrincipal,
    this.tematica,
    this.capituloActual,
    this.totalCapitulos,
    this.estadoPublicacion,
    this.tags,
  });

  factory FanfictionRespuestaDTO.fromJson(Map<String, dynamic> json) {
    return FanfictionRespuestaDTO(
      idFanfic: json['idFanfic'] as int?,
      ao3Id: json['ao3Id'] as String?,
      titulo: json['titulo'] as String?,
      autor: json['autor'] as String?,
      historiaBase: json['historiaBase'] as String?,
      descripcion: json['descripcion'] as String?,
      portadaUrl: json['portadaUrl'] as String?,
      genero: json['genero'] as String?,
      shipPrincipal: json['shipPrincipal'] as String?,
      tematica: json['tematica'] as String?,
      capituloActual: json['capituloActual'] as int?,
      totalCapitulos: json['totalCapitulos'] as int?,
      estadoPublicacion: json['estadoPublicacion'] as String?,
      tags: (json['tags'] as List?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idFanfic': idFanfic,
      'ao3Id': ao3Id,
      'titulo': titulo,
      'autor': autor,
      'historiaBase': historiaBase,
      'descripcion': descripcion,
      'portadaUrl': portadaUrl,
      'genero': genero,
      'shipPrincipal': shipPrincipal,
      'tematica': tematica,
      'capituloActual': capituloActual,
      'totalCapitulos': totalCapitulos,
      'estadoPublicacion': estadoPublicacion,
      'tags': tags,
    };
  }
}
