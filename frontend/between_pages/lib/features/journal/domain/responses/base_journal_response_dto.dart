abstract class BaseJournalResponseDTO {
  final int id;
  final int userId;
  final String status;
  final String? personalNotes;
  final String? startDate;
  final String? endDate;
  final int? rating;
  final int? tearDrops;
  final int? spiceFlames;
  final bool? rereading;
  final String? ownership;
  final String? readingFormat;
  final String? loanedTo;
  final String? updatedAt;

  // Campos que las clases hijas deben implementar
  final String? coverUrl;
  final String? title;
  final String? author;

  const BaseJournalResponseDTO({
    required this.id,
    required this.userId,
    required this.status,
    this.personalNotes,
    this.startDate,
    this.endDate,
    this.rating,
    this.tearDrops,
    this.spiceFlames,
    this.rereading,
    this.ownership,
    this.readingFormat,
    this.loanedTo,
    this.updatedAt,
    this.coverUrl,
    this.title,
    this.author,
  });
}
