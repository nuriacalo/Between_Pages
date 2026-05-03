/// DTO para solicitar la creación de una nueva lista de lectura.
class ReadingListRequestDTO {
  final String name;
  final String? description;

  ReadingListRequestDTO({
    required this.name,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}
