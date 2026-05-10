import 'package:between_pages/features/lists/domain/list_item_dto.dart';

class CustomListDTO {
  final int id;
  final String name;
  final String? description;
  final List<ListItemDTO> items;

  CustomListDTO({
    required this.id,
    required this.name,
    this.description,
    required this.items,
  });

  factory CustomListDTO.fromJson(Map<String, dynamic> json) {
    return CustomListDTO(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] as String,
      description: json['description'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => ListItemDTO.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}
