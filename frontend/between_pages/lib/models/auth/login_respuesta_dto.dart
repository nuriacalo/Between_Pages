class LoginResponseDTO {
  final String token;
  final String email;
  final String name;
  final String role;

  LoginResponseDTO({
    required this.token,
    required this.email,
    required this.name,
    required this.role,
  });

  factory LoginResponseDTO.fromJson(Map<String, dynamic> json) {
    return LoginResponseDTO(
      token: json['token'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'email': email, 'name': name, 'role': role};
  }
}
