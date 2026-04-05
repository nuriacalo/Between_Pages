class LoginRespuestaDTO {
  final String token;
  final String email;
  final String nombre;
  final String rol;

  LoginRespuestaDTO({
    required this.token,
    required this.email,
    required this.nombre,
    required this.rol,
  });

  factory LoginRespuestaDTO.fromJson(Map<String, dynamic> json) {
    return LoginRespuestaDTO(
      token: json['token'] as String,
      email: json['email'] as String,
      nombre: json['nombre'] as String,
      rol: json['rol'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'email': email, 'nombre': nombre, 'rol': rol};
  }
}
