import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/journal/application/providers/reading_timer_provider.dart';
import 'package:between_pages/features/journal/presentation/pages/diary_page.dart';
import 'package:between_pages/features/journal/presentation/pages/universal_session_page.dart';
import 'package:flutter/material.dart';
import 'base_journal_response_dto.dart';

class BookJournalResponseDto extends BaseJournalResponseDTO {
  final BookResponseDTO book;
  final int? currentPage;
  final List<String>? emotions;
  final String? favoriteQuotes;
  final String? seriesName;
  final double? seriesOrder;

  BookJournalResponseDto({
    required super.id,
    required super.userId,
    required this.book,
    required super.status,
    this.currentPage,
    super.rating,
    super.tearDrops,
    super.spiceFlames,
    super.readingFormat,
    this.emotions,
    this.favoriteQuotes,
    super.personalNotes,
    super.startDate,
    super.endDate,
    super.rereading,
    super.ownership,
    this.seriesName,
    this.seriesOrder,
    super.loanedTo,
  }) : super(
          coverUrl: book.coverUrl,
          title: book.title,
          author: book.author,
        );

  factory BookJournalResponseDto.fromJson(Map<String, dynamic> json) {
    return BookJournalResponseDto(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
      book: BookResponseDTO.fromJson(json['book'] as Map<String, dynamic>),
      status: json['status'] as String,
      currentPage: json['currentPage'] as int?,
      rating: json['rating'] as int?,
      tearDrops: json['tearDrops'] as int?,
      spiceFlames: json['spiceFlames'] as int?,
      readingFormat: json['readingFormat'] as String?,
      emotions: (json['emotions'] as List?)?.cast<String>(),
      favoriteQuotes: json['favoriteQuotes'] as String?,
      personalNotes: json['personalNotes'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      rereading: json['rereading'] as bool?,
      ownership: json['ownership'] as String?,
      seriesName: json['seriesName'] as String?,
      seriesOrder: (json['seriesOrder'] as num?)?.toDouble(),
      loanedTo: json['loanedTo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'book': book.toJson(),
      'status': status,
      'currentPage': currentPage,
      'rating': rating,
      'tearDrops': tearDrops,
      'spiceFlames': spiceFlames,
      'readingFormat': readingFormat,
      'emotions': emotions,
      'favoriteQuotes': favoriteQuotes,
      'personalNotes': personalNotes,
      'startDate': startDate,
      'endDate': endDate,
      'rereading': rereading,
      'ownership': ownership,
      'seriesName': seriesName,
      'seriesOrder': seriesOrder,
      'loanedTo': loanedTo,
    };
  }

  DiaryJournalData toDiaryData() {
    return DiaryJournalData(
      title: book.title,
      author: book.author,
      coverUrl: book.coverUrl,
      rating: rating,
      tearDrops: tearDrops,
      spiceFlames: spiceFlames,
      currentProgress: currentPage,
      personalNotes: personalNotes,
      progressLabel: 'Páginas leídas',
      icon: Icons.book,
      accentColor: Colors.blue,
    );
  }

  UniversalSessionData toSessionData() {
    return UniversalSessionData(
      mediaType: SessionMediaType.book,
      itemId: book.idBook,
      timerItemType: ReadingItemType.book,
      title: book.title,
      coverUrl: book.coverUrl,
      currentProgress: currentPage ?? 0,
      progressPrompt: '¿En qué página te has quedado?',
      accentColor: const Color(0xFFA87C80),
      rawJournal: this,
    );
  }
}
