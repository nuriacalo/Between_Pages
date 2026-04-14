class ListItemDTO {
  final int itemId;
  final String itemType; // 'BOOK', 'MANGA' o 'FANFIC'
  final String title;
  final String? coverUrl;
  final String author;

  ListItemDTO({
    required this.itemId,
    required this.itemType,
    required this.title,
    this.coverUrl,
    required this.author,
  });

  factory ListItemDTO.fromJson(Map<String, dynamic> json) {
    return ListItemDTO(
      itemId: int.tryParse(json['itemId']?.toString() ?? '0') ?? 0,
      itemType: json['itemType'] as String,
      title: json['title'] as String,
      coverUrl: json['coverUrl'] as String?,
      author: json['author'] ?? 'Autor desconocido', // Fallback si no hay autor
    );
  }
}
