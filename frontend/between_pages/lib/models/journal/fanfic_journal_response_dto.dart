
import 'package:between_pages/models/catalog/fanfiction_response_dto.dart';

class FanficJournalResponseDTO {
  final int idFanficJournal;
  final FanfictionResponseDTO fanfic;
  final String? estado;
  final int? capituloActual;
  final int? valoracion;
  final String? shipPrincipal;
  final String? shipsSecundarios;
  final String? nivelAngst;
  final String? canonVsAu;
  final bool? relectura;
  final String? notasPersonales;
  final String? fechaInicio;
  final String? fechaFin;

  FanficJournalResponseDTO({
    required this.idFanficJournal,
    required this.fanfic,
    this.estado,
    this.capituloActual,
    this.valoracion,
    this.shipPrincipal,
    this.shipsSecundarios,
    this.nivelAngst,
    this.canonVsAu,
    this.relectura,
    this.notasPersonales,
    this.fechaInicio,
    this.fechaFin,
  });

  factory FanficJournalResponseDTO.fromJson(Map<String, dynamic> json) {
    return FanficJournalResponseDTO(
      idFanficJournal: json['idFanficJournal'] as int,
      fanfic: FanfictionResponseDTO.fromJson(
        json['fanfic'] as Map<String, dynamic>,
      ),
      estado: json['estado'] as String?,
      capituloActual: json['capituloActual'] as int?,
      valoracion: json['valoracion'] as int?,
      shipPrincipal: json['shipPrincipal'] as String?,
      shipsSecundarios: json['shipsSecundarios'] as String?,
      nivelAngst: json['nivelAngst'] as String?,
      canonVsAu: json['canonVsAu'] as String?,
      relectura: json['relectura'] as bool?,
      notasPersonales: json['notasPersonales'] as String?,
      fechaInicio: json['fechaInicio'] as String?,
      fechaFin: json['fechaFin'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idFanficJournal': idFanficJournal,
      'fanfic': fanfic.toJson(),
      'estado': estado,
      'capituloActual': capituloActual,
      'valoracion': valoracion,
      'shipPrincipal': shipPrincipal,
      'shipsSecundarios': shipsSecundarios,
      'nivelAngst': nivelAngst,
      'canonVsAu': canonVsAu,
      'relectura': relectura,
      'notasPersonales': notasPersonales,
      'fechaInicio': fechaInicio,
      'fechaFin': fechaFin,
    };
  }
}
