class NoteDTO {
  final int? id;
  final int userId;
  final int bookId;
  final String? quote;
  final String? note;
  final int? page;
  final DateTime? createdAt;

  const NoteDTO({
    this.id,
    required this.userId,
    required this.bookId,
    this.quote,
    this.note,
    this.page,
    this.createdAt,
  });

  factory NoteDTO.fromJson(Map<String, dynamic> json) => NoteDTO(
        id: json['id'] as int?,
        userId: json['userId'] as int,
        bookId: json['bookId'] as int,
        quote: json['quote'] as String?,
        note: json['note'] as String?,
        page: json['page'] as int?,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'userId': userId,
        'bookId': bookId,
        if (quote != null) 'quote': quote,
        if (note != null) 'note': note,
        if (page != null) 'page': page,
      };
}