class ListResponseDTO {
  final int id;
  final String name;

  ListResponseDTO({required this.id, required this.name});

  factory ListResponseDTO.fromJson(Map<String, dynamic> json) {
    return ListResponseDTO(id: json['id'] as int, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
