import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/journal/application/providers/reading_timer_provider.dart';
import 'package:between_pages/features/journal/presentation/pages/diary_page.dart';
import 'package:between_pages/features/journal/presentation/pages/universal_session_page.dart';
import 'package:flutter/material.dart';
import 'base_journal_response_dto.dart';

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

  factory FanficJournalResponseDTO.fromJson(Map<String, dynamic> json) {
    return FanficJournalResponseDTO(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
      fanfic: FanfictionResponseDTO.fromJson(
        json['fanfic'] as Map<String, dynamic>,
      ),
      status: json['status'] as String,
      currentChapter: json['currentChapter'] as int?,
      rating: json['rating'] as int?,
      tearDrops: json['tearDrops'] as int?,
      spiceFlames: json['spiceFlames'] as int?,
      mainShip: json['mainShip'] as String?,
      secondaryShips: json['secondaryShips'] as String?,
      theme: json['theme'] as String?,
      angstLevel: json['angstLevel'] as String?,
      shipLoyalty: json['shipLoyalty'] as String?,
      canonType: json['canonType'] as String?,
      rereading: json['rereading'] as bool?,
      personalNotes: json['personalNotes'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fanfic': fanfic.toJson(),
      'status': status,
      'currentChapter': currentChapter,
      'rating': rating,
      'tearDrops': tearDrops,
      'spiceFlames': spiceFlames,
      'mainShip': mainShip,
      'secondaryShips': secondaryShips,
      'theme': theme,
      'angstLevel': angstLevel,
      'shipLoyalty': shipLoyalty,
      'canonType': canonType,
      'rereading': rereading,
      'personalNotes': personalNotes,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

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
      progressPrompt: '¿En qué capítulo te has quedado?',
      accentColor: const Color(0xFFD4A0A4),
      rawJournal: this,
    );
  }
}
