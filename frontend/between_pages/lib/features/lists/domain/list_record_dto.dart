class ListaRecordDTO {
  final int userId;
  final String name;
  final String? description;

  ListaRecordDTO({required this.userId, required this.name, this.description});

  factory ListaRecordDTO.fromJson(Map<String, dynamic> json) {
    return ListaRecordDTO(
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'name': name, 'description': description};
  }
}
