import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/journal/application/providers/reading_timer_provider.dart';
import 'package:between_pages/features/journal/presentation/pages/diary_page.dart';
import 'package:between_pages/features/journal/presentation/pages/universal_session_page.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'base_journal_response_dto.dart';

part 'fanfic_journal_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class FanficJournalResponseDTO extends BaseJournalResponseDTO {
  final FanfictionResponseDTO fanfic;
  final int? currentChapter;
  final String? mainShip;
  final String? secondaryShips;
  final String? theme;
  final String? angstLevel;
  final String? shipLoyalty;
  final String? canonType;

  FanficJournalResponseDTO({
    required super.id,
    required super.userId,
    required this.fanfic,
    required super.status,
    this.currentChapter,
    super.rating,
    super.tearDrops,
    super.spiceFlames,
    this.mainShip,
    this.secondaryShips,
    this.theme,
    this.angstLevel,
    this.shipLoyalty,
    this.canonType,
    super.rereading,
    super.personalNotes,
    super.startDate,
    super.endDate,
  }) : super(
          coverUrl: fanfic.coverUrl,
          title: fanfic.title,
          author: fanfic.author,
        );

  factory FanficJournalResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$FanficJournalResponseDTOFromJson(json);

  Map<String, dynamic> toJson() => _$FanficJournalResponseDTOToJson(this);

  DiaryJournalData toDiaryData() {
    return DiaryJournalData(
      title: fanfic.title ?? 'Sin título',
      author: fanfic.author ?? 'Autor desconocido',
      coverUrl: fanfic.coverUrl,
      rating: rating,
      tearDrops: tearDrops,
      spiceFlames: spiceFlames,
      currentProgress: currentChapter,
      personalNotes: personalNotes,
      progressLabel: 'Capítulos leídos',
      icon: Icons.favorite,
      accentColor: Colors.pink,
    );
  }

  UniversalSessionData toSessionData() {
    return UniversalSessionData(
      mediaType: SessionMediaType.fanfic,
      itemId: fanfic.idFanfic ?? 0,
      timerItemType: ReadingItemType.fanfic,
      title: fanfic.title ?? 'Sin título',
      coverUrl: fanfic.coverUrl,
      currentProgress: currentChapter ?? 0,
      totalProgress: fanfic.totalChapters,
      progressPrompt: '¿En qué capítulo te has quedado?',
      accentColor: const Color(0xFFD4A0A4),
      rawJournal: this,
    );
  }
}
