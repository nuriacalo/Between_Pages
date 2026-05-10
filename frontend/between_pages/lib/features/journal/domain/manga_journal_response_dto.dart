import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/journal/application/providers/reading_timer_provider.dart';
import 'package:between_pages/features/journal/presentation/pages/diary_page.dart';
import 'package:between_pages/features/journal/presentation/pages/universal_session_page.dart';
import 'package:flutter/material.dart';
import 'base_journal_response_dto.dart';

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
      userId: int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
      manga: manga,
      status: json['status'] as String,
      currentChapter: json['currentChapter'] as int?,
      currentVolume: json['currentVolume'] as int?,
      rating: json['rating'] as int?,
      tearDrops: json['tearDrops'] as int?,
      spiceFlames: json['spiceFlames'] as int?,
      readingFormat: json['readingFormat'] as String?,
      favoriteCharacter: json['favoriteCharacter'] as String?,
      favoriteArc: json['favoriteArc'] as String?,
      personalNotes: json['personalNotes'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      rereading: json['rereading'] as bool?,
      ownership: json['ownership'] as String?,
      loanedTo: json['loanedTo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'manga': manga?.toJson(),
      'status': status,
      'currentChapter': currentChapter,
      'currentVolume': currentVolume,
      'rating': rating,
      'tearDrops': tearDrops,
      'spiceFlames': spiceFlames,
      'readingFormat': readingFormat,
      'favoriteCharacter': favoriteCharacter,
      'favoriteArc': favoriteArc,
      'personalNotes': personalNotes,
      'startDate': startDate,
      'endDate': endDate,
      'rereading': rereading,
      'ownership': ownership,
      'loanedTo': loanedTo,
    };
  }

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
