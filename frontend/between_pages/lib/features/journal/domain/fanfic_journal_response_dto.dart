import 'package:between_pages/screens/journal/diary_page.dart';
import 'package:between_pages/screens/journal/universal_session_page.dart';
import 'package:between_pages/providers/journal/reading_timer_provider.dart';
import 'package:flutter/material.dart';
import '../catalog/fanfiction_response_dto.dart';
import 'base_journal_response_dto.dart';

class FanficJournalResponseDTO implements BaseJournalResponseDTO {
  final int id;
  final int userId;
  final FanfictionResponseDTO fanfic;
  final String? status;
  final int? currentChapter;
  final int? rating;
  final int? tearDrops;
  final int? spiceFlames;
  final String? mainShip;
  final String? secondaryShips;
  final String? theme;
  final String? angstLevel;
  final String? shipLoyalty;
  final String? canonType;
  final bool? rereading;
  final String? personalNotes;
  final String? startDate;
  final String? endDate;

  FanficJournalResponseDTO({
    required this.id,
    required this.userId,
    required this.fanfic,
    this.status,
    this.currentChapter,
    this.rating,
    this.tearDrops,
    this.spiceFlames,
    this.mainShip,
    this.secondaryShips,
    this.theme,
    this.angstLevel,
    this.shipLoyalty,
    this.canonType,
    this.rereading,
    this.personalNotes,
    this.startDate,
    this.endDate,
  });

  factory FanficJournalResponseDTO.fromJson(Map<String, dynamic> json) {
    return FanficJournalResponseDTO(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      fanfic: FanfictionResponseDTO.fromJson(
        json['fanfic'] as Map<String, dynamic>,
      ),
      status: json['status'] as String?,
      currentChapter: json['current_chapter'] as int?,
      rating: json['rating'] as int?,
      tearDrops: json['tear_drops'] as int?,
      spiceFlames: json['spice_flames'] as int?,
      mainShip: json['main_ship'] as String?,
      secondaryShips: json['secondary_ships'] as String?,
      theme: json['theme'] as String?,
      angstLevel: json['angst_level'] as String?,
      shipLoyalty: json['ship_loyalty'] as String?,
      canonType: json['canon_type'] as String?,
      rereading: json['rereading'] as bool?,
      personalNotes: json['personal_notes'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'fanfic': fanfic.toJson(),
      'status': status,
      'current_chapter': currentChapter,
      'rating': rating,
      'tear_drops': tearDrops,
      'spice_flames': spiceFlames,
      'main_ship': mainShip,
      'secondary_ships': secondaryShips,
      'theme': theme,
      'angst_level': angstLevel,
      'ship_loyalty': shipLoyalty,
      'canon_type': canonType,
      'rereading': rereading,
      'personal_notes': personalNotes,
      'start_date': startDate,
      'end_date': endDate,
    };
  }

  @override
  String? get coverUrl => fanfic.coverUrl;

  @override
  String? get title => fanfic.title;

  @override
  String? get author => fanfic.author;

  @override
  String? get ownership => null;

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


extension FanficJournalMapper on FanficJournalResponseDTO {
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