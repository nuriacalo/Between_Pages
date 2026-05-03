class ReadingSessionRecordDTO {
  final int userId;
  final int? bookId;
  final int? mangaId;
  final int? fanficId;
  final int durationSeconds;
  final int pagesRead;

  ReadingSessionRecordDTO({
    required this.userId,
    this.bookId,
    this.mangaId,
    this.fanficId,
    required this.durationSeconds,
    required this.pagesRead,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'user_id': userId,
      'duration_seconds': durationSeconds,
      'pages_read': pagesRead,
    };
    if (bookId != null) {
      data['book_id'] = bookId;
    }
    if (mangaId != null) {
      data['manga_id'] = mangaId;
    }
    if (fanficId != null) {
      data['fanfic_id'] = fanficId;
    }
    return data;
  }
}