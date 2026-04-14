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
      idUser: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] as String? ?? 'Usuario',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'USER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': idUser,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
