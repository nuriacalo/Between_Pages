class ListaRecordDTO {
  final int userId;
  final String name;

  ListaRecordDTO({required this.userId, required this.name});

  factory ListaRecordDTO.fromJson(Map<String, dynamic> json) {
    return ListaRecordDTO(
      userId: json['user_id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'name': name};
  }
}
