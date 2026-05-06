import 'package:flutter/material.dart';
import 'package:between_pages/models/journal/book_journal_response_dto.dart';
import 'package:between_pages/models/journal/manga_journal_response_dto.dart';
import 'package:between_pages/models/journal/fanfic_journal_response_dto.dart';
import 'package:between_pages/screens/journal/diary_page.dart';
import 'package:between_pages/screens/journal/universal_session_page.dart';
import 'package:between_pages/providers/journal/reading_timer_provider.dart';

extension BookJournalMapper on BookJournalResponseDto {
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
      accentColor: Colors.blue, // Puedes usar Theme.of(context) en la vista si prefieres
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