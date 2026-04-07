class UserRegistrationDTO {
  final String name;
  final String email;
  final String password;

  UserRegistrationDTO({
    required this.name,
    required this.email,
    required this.password,
  });

  factory UserRegistrationDTO.fromJson(Map<String, dynamic> json) {
    return UserRegistrationDTO(
      name: json['nombre'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'nombre': name, 'email': email, 'password': password};
  }
}
