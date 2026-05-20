import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/journal/application/providers/reading_timer_provider.dart';
import 'package:between_pages/features/journal/presentation/pages/diary_page.dart';
import 'package:between_pages/features/journal/presentation/pages/universal_session_page.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'base_journal_response_dto.dart';

part 'book_journal_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
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

  factory BookJournalResponseDto.fromJson(Map<String, dynamic> json) =>
      _$BookJournalResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BookJournalResponseDtoToJson(this);

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
      itemId: book.idBook ?? 0,
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
