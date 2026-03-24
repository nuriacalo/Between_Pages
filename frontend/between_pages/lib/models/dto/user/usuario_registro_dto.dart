class UsuarioRegistroDTO {
  final String nombre;
  final String email;
  final String password;

  UsuarioRegistroDTO({
    required this.nombre,
    required this.email,
    required this.password,
  });

  factory UsuarioRegistroDTO.fromJson(Map<String, dynamic> json) {
    return UsuarioRegistroDTO(
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'nombre': nombre, 'email': email, 'password': password};
  }
}
