class UsuarioRespuestaDTO {
  final int idUsuario;
  final String nombre;
  final String email;
  final String rol;

  UsuarioRespuestaDTO({
    required this.idUsuario,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  factory UsuarioRespuestaDTO.fromJson(Map<String, dynamic> json) {
    return UsuarioRespuestaDTO(
      idUsuario: json['idUsuario'] as int,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      rol: json['rol'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
      'nombre': nombre,
      'email': email,
      'rol': rol,
    };
  }
}
