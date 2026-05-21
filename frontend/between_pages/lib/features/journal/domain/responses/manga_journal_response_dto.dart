import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/journal/application/providers/reading_timer_provider.dart';
import 'package:between_pages/features/journal/presentation/pages/diary_page.dart';
import 'package:between_pages/features/journal/presentation/pages/universal_session_page.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'base_journal_response_dto.dart';

part 'manga_journal_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class MangaJournalResponseDTO extends BaseJournalResponseDTO {
  final MangaResponseDTO? manga;
  final int? currentChapter;
  final int? currentVolume;
  final String? favoriteCharacter;
  final String? favoriteArc;

  MangaJournalResponseDTO({
    required super.id,
    required super.userId,
    this.manga,
    required super.status,
    this.currentChapter,
    this.currentVolume,
    super.rating,
    super.tearDrops,
    super.spiceFlames,
    super.readingFormat,
    this.favoriteCharacter,
    this.favoriteArc,
    super.personalNotes,
    super.startDate,
    super.endDate,
    super.rereading,
    super.ownership,
    super.loanedTo,
  }) : super(
          coverUrl: manga?.coverUrl,
          title: manga?.title,
          author: manga?.author,
        );

  factory MangaJournalResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$MangaJournalResponseDTOFromJson(json);

  Map<String, dynamic> toJson() => _$MangaJournalResponseDTOToJson(this);

  DiaryJournalData toDiaryData() {
    return DiaryJournalData(
      title: manga?.title ?? 'Sin título',
      author: manga?.author ?? 'Autor desconocido',
      coverUrl: manga?.coverUrl,
      rating: rating,
      tearDrops: tearDrops,
      spiceFlames: spiceFlames,
      currentProgress: currentChapter,
      personalNotes: personalNotes,
      progressLabel: 'Capítulos leídos',
      icon: Icons.auto_stories,
      accentColor: Colors.deepPurple,
    );
  }

  UniversalSessionData toSessionData() {
    return UniversalSessionData(
      mediaType: SessionMediaType.manga,
      itemId: manga?.idManga ?? 0,
      timerItemType: ReadingItemType.manga,
      title: manga?.title ?? 'Sin título',
      coverUrl: manga?.coverUrl,
      currentProgress: currentChapter ?? 0,
      totalProgress: manga?.totalChapters,
      progressPrompt: '¿En qué capítulo/volumen te has quedado?',
      accentColor: const Color(0xFF6B7280),

      rawJournal: this,
    );
  }
}
