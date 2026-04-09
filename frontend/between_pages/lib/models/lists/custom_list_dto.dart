import 'package:between_pages/models/lists/list_item_dto.dart';

class CustomListDTO {
  final int idList;
  final String name;
  final String? description;
  final List<ListItemDTO> items;

  CustomListDTO({
    required this.idList,
    required this.name,
    this.description,
    required this.items,
  });

  factory CustomListDTO.fromJson(Map<String, dynamic> json) {
    return CustomListDTO(
      idList: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => ListItemDTO.fromJson(e))
              .toList() ??
          [],
    );
  }
}
