class ListResponseDTO {
  final int id;
  final String name;
  final String? description;

  ListResponseDTO({required this.id, required this.name, this.description});

  factory ListResponseDTO.fromJson(Map<String, dynamic> json) {
    return ListResponseDTO(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }
}
