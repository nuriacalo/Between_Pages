class ListaRegistroDTO {
  final int idUsuario;
  final String nombre;

  ListaRegistroDTO({required this.idUsuario, required this.nombre});

  factory ListaRegistroDTO.fromJson(Map<String, dynamic> json) {
    return ListaRegistroDTO(
      idUsuario: json['idUsuario'] as int,
      nombre: json['nombre'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'idUsuario': idUsuario, 'nombre': nombre};
  }
}
