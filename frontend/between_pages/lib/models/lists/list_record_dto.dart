class ListaRecordDTO {
  final int idUsuario;
  final String nombre;

  ListaRecordDTO({required this.idUsuario, required this.nombre});

  factory ListaRecordDTO.fromJson(Map<String, dynamic> json) {
    return ListaRecordDTO(
      idUsuario: json['idUsuario'] as int,
      nombre: json['nombre'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'idUsuario': idUsuario, 'nombre': nombre};
  }
}
