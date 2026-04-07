class FanficJournalRecordDTO {
  final int idUsuario;
  final int? idFanfiction;

  final String? ao3Id;
  final String? titulo;
  final String? autor;
  final String? historiaBase;
  final String? descripcion;
  final String? portadaUrl;
  final String? genero;
  final String? tematica;
  final int? totalCapitulos;
  final String? estadoPublicacion;

  final String estado;
  final int? capituloActual;
  final int? valoracion;

  final String? shipPrincipal;
  final String? shipsSecundarios;

  final int? nivelAngst;
  final int? fidelidadShip;

  final String? canonVsAu;

  final bool? relectura;
  final String? notasPersonales;

  final String? fechaInicio;
  final String? fechaFin;

  FanficJournalRecordDTO({
    required this.idUsuario,
    this.idFanfiction,
    this.ao3Id,
    this.titulo,
    this.autor,
    this.historiaBase,
    this.descripcion,
    this.portadaUrl,
    this.genero,
    this.tematica,
    this.totalCapitulos,
    this.estadoPublicacion,
    required this.estado,
    this.capituloActual,
    this.valoracion,
    this.shipPrincipal,
    this.shipsSecundarios,
    this.nivelAngst,
    this.fidelidadShip,
    this.canonVsAu,
    this.relectura,
    this.notasPersonales,
    this.fechaInicio,
    this.fechaFin,
  });

  factory FanficJournalRecordDTO.fromJson(Map<String, dynamic> json) {
    return FanficJournalRecordDTO(
      idUsuario: json['idUsuario'] as int,
      idFanfiction: json['idFanfiction'] as int?,
      ao3Id: json['ao3Id'] as String?,
      titulo: json['titulo'] as String?,
      autor: json['autor'] as String?,
      historiaBase: json['historiaBase'] as String?,
      descripcion: json['descripcion'] as String?,
      portadaUrl: json['portadaUrl'] as String?,
      genero: json['genero'] as String?,
      tematica: json['tematica'] as String?,
      totalCapitulos: json['totalCapitulos'] as int?,
      estadoPublicacion: json['estadoPublicacion'] as String?,
      estado: json['estado'] as String,
      capituloActual: json['capituloActual'] as int?,
      valoracion: json['valoracion'] as int?,
      shipPrincipal: json['shipPrincipal'] as String?,
      shipsSecundarios: json['shipsSecundarios'] as String?,
      nivelAngst: json['nivelAngst'] as int?,
      fidelidadShip: json['fidelidadShip'] as int?,
      canonVsAu: json['canonVsAu'] as String?,
      relectura: json['relectura'] as bool?,
      notasPersonales: json['notasPersonales'] as String?,
      fechaInicio: json['fechaInicio'] as String?,
      fechaFin: json['fechaFin'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
      'idFanfiction': idFanfiction,
      'ao3Id': ao3Id,
      'titulo': titulo,
      'autor': autor,
      'historiaBase': historiaBase,
      'descripcion': descripcion,
      'portadaUrl': portadaUrl,
      'genero': genero,
      'tematica': tematica,
      'totalCapitulos': totalCapitulos,
      'estadoPublicacion': estadoPublicacion,
      'estado': estado,
      'capituloActual': capituloActual,
      'valoracion': valoracion,
      'shipPrincipal': shipPrincipal,
      'shipsSecundarios': shipsSecundarios,
      'nivelAngst': nivelAngst,
      'fidelidadShip': fidelidadShip,
      'canonVsAu': canonVsAu,
      'relectura': relectura,
      'notasPersonales': notasPersonales,
      'fechaInicio': fechaInicio,
      'fechaFin': fechaFin,
    };
  }
}
