class UserResponseDTO {
  final int idUser;
  final String name;
  final String email;
  final String role;

  UserResponseDTO({
    required this.idUser,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserResponseDTO.fromJson(Map<String, dynamic> json) {
    return UserResponseDTO(
      idUser: json['idUsuario'] as int? ?? 0,
      name: json['nombre'] as String? ?? 'Usuario',
      email: json['email'] as String? ?? '',
      role: json['rol'] as String? ?? 'USER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUser,
      'nombre': name,
      'email': email,
      'rol': role,
    };
  }
}
