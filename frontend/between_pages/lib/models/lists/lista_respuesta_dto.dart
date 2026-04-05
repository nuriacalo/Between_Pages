class ListaRespuestaDTO {
  final int idLista;
  final String nombre;

  ListaRespuestaDTO({required this.idLista, required this.nombre});

  factory ListaRespuestaDTO.fromJson(Map<String, dynamic> json) {
    return ListaRespuestaDTO(
      idLista: json['idLista'] as int,
      nombre: json['nombre'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'idLista': idLista, 'nombre': nombre};
  }
}
