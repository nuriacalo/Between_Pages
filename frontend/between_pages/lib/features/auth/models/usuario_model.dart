// lib/features/auth/models/usuario_model.dart
class UsuarioModel {
  final String token;
  final String email;
  final String nombre;
  final String rol;

  UsuarioModel({
    required this.token,
    required this.email,
    required this.nombre,
    required this.rol,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      token: json['token'],
      email: json['email'],
      nombre: json['nombre'],
      rol: json['rol'],
    );
  }
}