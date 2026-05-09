import 'package:between_pages/screens/journal/diary_page.dart';
import 'package:between_pages/screens/journal/universal_session_page.dart';
import 'package:between_pages/providers/journal/reading_timer_provider.dart';
import 'package:flutter/material.dart';
import '../catalog/manga_response_dto.dart';
import 'base_journal_response_dto.dart';

class MangaJournalResponseDTO implements BaseJournalResponseDTO {
  final int id;
  final int userId;
  final MangaResponseDTO? manga;
  final String? status;
  final int? currentChapter;
  final int? currentVolume;
  final int? rating;
  final int? tearDrops;
  final int? spiceFlames;
  final String? readingFormat;
  final String? favoriteCharacter;
  final String? favoriteArc;
  final String? personalNotes;
  final String? startDate;
  final String? endDate;
  final bool? rereading;
  final String? ownership;
  final String? loanedTo;

  MangaJournalResponseDTO({
    required this.id,
    required this.userId,
    this.manga,
    this.status,
    this.currentChapter,
    this.currentVolume,
    this.rating,
    this.tearDrops,
    this.spiceFlames,
    this.readingFormat,
    this.favoriteCharacter,
    this.favoriteArc,
    this.personalNotes,
    this.startDate,
    this.endDate,
    this.rereading,
    this.ownership,
    this.loanedTo,
  });

  factory MangaJournalResponseDTO.fromJson(Map<String, dynamic> json) {
    MangaResponseDTO? manga;
    final mangaJson = json['manga'];
    if (mangaJson != null && mangaJson is Map<String, dynamic>) {
      try {
        manga = MangaResponseDTO.fromJson(mangaJson);
      } catch (e) {
        manga = null;
      }
    }

    return MangaJournalResponseDTO(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      manga: manga,
      status: json['status'] as String?,
      currentChapter: json['current_chapter'] as int?,
      currentVolume: json['current_volume'] as int?,
      rating: json['rating'] as int?,
      tearDrops: json['tear_drops'] as int?,
      spiceFlames: json['spice_flames'] as int?,
      readingFormat: json['reading_format'] as String?,
      favoriteCharacter: json['favorite_character'] as String?,
      favoriteArc: json['favorite_arc'] as String?,
      personalNotes: json['personal_notes'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      rereading: json['rereading'] as bool?,
      ownership: json['ownership'] as String?,
      loanedTo: json['loaned_to'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'manga': manga?.toJson(),
      'status': status,
      'current_chapter': currentChapter,
      'current_volume': currentVolume,
      'rating': rating,
      'tear_drops': tearDrops,
      'spice_flames': spiceFlames,
      'reading_format': readingFormat,
      'favorite_character': favoriteCharacter,
      'favorite_arc': favoriteArc,
      'personal_notes': personalNotes,
      'start_date': startDate,
      'end_date': endDate,
      'rereading': rereading,
      'ownership': ownership,
      'loaned_to': loanedTo,
    };
  }

  @override
  String? get coverUrl => manga?.coverUrl;

  @override
  String? get title => manga?.title;

  @override
  String? get author => manga?.author;

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
      progressPrompt: '¿En qué capítulo/volumen te has quedado?',
      accentColor: const Color(0xFF6B7280),
      rawJournal: this,
    );
  }
}

extension MangaJournalMapper on MangaJournalResponseDTO {
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
      progressPrompt: '¿En qué capítulo/volumen te has quedado?',
      accentColor: const Color(0xFF6B7280),
      rawJournal: this,
    );
  }
}