class ListResponseDTO {
  final int idLista;
  final String nombre;

  ListResponseDTO({required this.idLista, required this.nombre});

  factory ListResponseDTO.fromJson(Map<String, dynamic> json) {
    return ListResponseDTO(
      idLista: json['idLista'] as int,
      nombre: json['nombre'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'idLista': idLista, 'nombre': nombre};
  }
}
