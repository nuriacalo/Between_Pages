import 'package:between_pages/core/theme/app_colors.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/catalog/application/repositories/catalog_repository.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/auth/application/repositories/auth_repository.dart';
import 'package:between_pages/features/catalog/presentation/pages/item_reading_stats_provider.dart';
import 'package:between_pages/features/profile/application/providers/gamification_provider.dart';
import 'package:between_pages/features/profile/application/repositories/reading_stats_repository.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/domain/records/book_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/manga_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/records/fanfic_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/responses/book_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/manga_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/fanfic_journal_response_dto.dart';
import 'package:between_pages/features/journal/presentation/pages/journal_item_edit_page.dart';
import 'package:between_pages/features/journal/domain/utils/journal_status_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _kBookAccent = AppColors.colorLibro;
const _kMangaAccent = AppColors.colorManga;
const _kFanficAccent = AppColors.colorFanfic;

class BookReadingProgressPage extends ConsumerStatefulWidget {
  final BookJournalResponseDto journal;
  const BookReadingProgressPage({super.key, required this.journal});

  @override
  ConsumerState<BookReadingProgressPage> createState() =>
      _BookReadingProgressPageState();
}

class _BookReadingProgressPageState
    extends ConsumerState<BookReadingProgressPage> {
  bool _isSaving = false;
  int? _currentPageLocal;
  int? _totalPagesLocal;

  BookJournalResponseDto get _journal => widget.journal;
  BookResponseDTO get _book => _journal.book;

  int? get _totalPages => _totalPagesLocal ?? _book.pageCount;
  int get _currentPage => _currentPageLocal ?? _journal.currentPage ?? 0;

  Future<void> _updatePage(int newPage) async {
    if (_isSaving) return;
    final previousPage = _currentPageLocal;
    setState(() {
      _isSaving = true;
      _currentPageLocal = newPage;
    });
    try {
      final auth = ref.read(authRepositoryProvider);
      final repo = ref.read(bookJournalRepositoryProvider);
      final user = await auth.getUserProfile();
      final dto = BookJournalRecordDTO(
        id: _journal.id,
        userId: user.idUser,
        bookId: _book.idBook,
        googleBooksId: _book.googleBooksId != null && _book.googleBooksId!.isNotEmpty
            ? _book.googleBooksId
            : null,
        status: JournalStatusHelper.mapStatusToDb(_journal.status),
        currentPage: newPage,
        rating: _journal.rating,
        tearDrops: _journal.tearDrops,
        spiceFlames: _journal.spiceFlames,
        readingFormat: _journal.readingFormat,
        emotions: _journal.emotions,
        favoriteQuotes: _journal.favoriteQuotes,
        personalNotes: _journal.personalNotes,
        startDate: _journal.startDate,
        endDate: _journal.endDate,
        ownership: _journal.ownership,
      );
      await repo.saveRaw(dto.toJson());
      try {
        await ref.read(readingStatsRepositoryProvider).recordActivity();
        ref.invalidate(gamificationProvider);
      } catch (e) {
        debugPrint('Error al registrar actividad: $e');
      }
      ref.invalidate(journalProvider(JournalType.book));
      ref.invalidate(journalEntryProvider((JournalType.book, _book.idBook ?? 0)));
      if (mounted) _showSuccessSnack('Progreso actualizado');
    } catch (e) {
      if (mounted) {
        setState(() => _currentPageLocal = previousPage);
        _showErrorSnack('Error al actualizar: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveTotalPages(int totalPages) async {
    final previousTotal = _totalPagesLocal;
    setState(() {
      _isSaving = true;
      _totalPagesLocal = totalPages;
    });
    try {
      final repo = ref.read(catalogRepositoryProvider);
      final bookToSave = BookResponseDTO(
        idBook: _book.idBook,
        googleBooksId: _book.googleBooksId,
        title: _book.title,
        author: _book.author,
        pageCount: totalPages,
        coverUrl: _book.coverUrl,
        isbn: _book.isbn,
        publisher: _book.publisher,
        publishYear: _book.publishYear,
        description: _book.description,
        genres: _book.genres,
        bookType: _book.bookType,
      );
      await repo.saveOrUpdateBook(bookToSave);
      ref.invalidate(journalProvider(JournalType.book));
      ref.invalidate(journalEntryProvider((JournalType.book, _book.idBook ?? 0)));
      if (mounted) {
        _showSuccessSnack('Total de páginas guardado');
        _showUpdatePageSheet(knownTotal: totalPages);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _totalPagesLocal = previousTotal);
        _showErrorSnack('Error al guardar páginas: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSuccessSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_outline, color: Colors.white),
        const SizedBox(width: 8),
        Text(msg),
      ]),
      backgroundColor: AppColors.statusReading,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Theme.of(context).colorScheme.error,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _promptForTotalPages() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => _TotalDialog(
        controller: controller,
        title: 'Falta información',
        body: 'Para hacer un seguimiento adecuado, necesitamos saber cuántas páginas tiene este libro.',
        label: 'Total de páginas',
        icon: Icons.auto_stories_rounded,
        accent: _kBookAccent,
        onConfirm: (val) {
          if (val != null && val > 0) {
            Navigator.pop(context);
            _saveTotalPages(val);
          }
        },
      ),
    );
  }

  void _showUpdatePageSheet({int? knownTotal}) {
    final total = knownTotal ?? _totalPages;
    if (total == null || total <= 0) {
      _promptForTotalPages();
      return;
    }
    _showProgressSheet(
      title: _book.title,
      label: 'Página actual (de $total)',
      icon: Icons.menu_book_outlined,
      currentValue: _currentPage,
      accent: _kBookAccent,
      isSaving: _isSaving,
      onSave: (val) {
        Navigator.pop(context);
        _updatePage(val);
      },
    );
  }

  void _showProgressSheet({
    required String title,
    required String label,
    required IconData icon,
    required int currentValue,
    required Color accent,
    required bool isSaving,
    required void Function(int) onSave,
  }) {
    final controller = TextEditingController(text: currentValue.toString());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProgressSheet(
        title: title,
        fieldLabel: label,
        fieldIcon: icon,
        controller: controller,
        accent: accent,
        isSaving: isSaving,
        onSave: onSave,
      ),
    );
  }

  void _goToEditJournal() => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                JournalItemEditPage(journal: _journal, type: JournalType.book)),
      );

  @override
  Widget build(BuildContext context) {
    final updatedJournal =
        ref.watch(journalEntryProvider((JournalType.book, _book.idBook ?? 0)));
    final journal = (updatedJournal as BookJournalResponseDto?) ?? _journal;
    final book = journal.book;

    final currentPage = _currentPageLocal ?? journal.currentPage ?? 0;
    final totalPages = _totalPagesLocal ?? book.pageCount;
    final progress = (totalPages ?? 0) > 0
        ? (currentPage / totalPages!).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          _CoverAppBar(
            title: book.title,
            coverUrl: book.coverUrl,
            accent: _kBookAccent,
            typeLabel: 'Libro',
            typeIcon: Icons.book_rounded,
          ),
        ],
        body: _ProgressBody(
          accent: _kBookAccent,
          currentProgress: currentPage,
          totalProgress: totalPages,
          progress: progress,
          progressLabel: 'Página',
          sessionRoute: '/journal/book/session',
          rawJournal: _journal,
          isSaving: _isSaving,
          onUpdateProgress: _showUpdatePageSheet,
          onEditJournal: _goToEditJournal,
          statsWidget: _StatsGrid(
            accent: _kBookAccent,
            startDate: journal.startDate,
            currentProgress: currentPage,
            totalProgress: totalPages,
            itemId: book.idBook,
            progressLabel: 'Págs.',
          ),
        ),
      ),
    );
  }
}

class MangaReadingProgressPage extends ConsumerStatefulWidget {
  final MangaJournalResponseDTO journal;
  const MangaReadingProgressPage({super.key, required this.journal});

  @override
  ConsumerState<MangaReadingProgressPage> createState() =>
      _MangaReadingProgressPageState();
}

class _MangaReadingProgressPageState
    extends ConsumerState<MangaReadingProgressPage> {
  bool _isSaving = false;
  int? _currentChapterLocal;
  int? _totalChaptersLocal;

  MangaJournalResponseDTO get _journal => widget.journal;
  MangaResponseDTO get _manga => _journal.manga!;

  int? get _totalChapters => _totalChaptersLocal ?? _manga.totalChapters;
  int get _currentChapter => _currentChapterLocal ?? _journal.currentChapter ?? 0;

  Future<void> _updateChapter(int newChapter) async {
    if (_isSaving) return;
    final previousChapter = _currentChapterLocal;
    setState(() {
      _isSaving = true;
      _currentChapterLocal = newChapter;
    });
    try {
      final auth = ref.read(authRepositoryProvider);
      final repo = ref.read(mangaJournalRepositoryProvider);
      final user = await auth.getUserProfile();
      final dto = MangaJournalRecordDTO(
        id: _journal.id,
        userId: user.idUser,
        mangaId: _manga.idManga,
        malId: _manga.malId,
        status: JournalStatusHelper.mapStatusToDb(_journal.status),
        currentChapter: newChapter,
        currentVolume: _journal.currentVolume,
        rating: _journal.rating,
        tearDrops: _journal.tearDrops,
        spiceFlames: _journal.spiceFlames,
        readingFormat: _journal.readingFormat,
        favoriteCharacter: _journal.favoriteCharacter,
        favoriteArc: _journal.favoriteArc,
        personalNotes: _journal.personalNotes,
        startDate: _journal.startDate,
        endDate: _journal.endDate,
        ownership: _journal.ownership,
        rereading: _journal.rereading,
      );
      await repo.saveRaw(dto.toJson());
      try {
        await ref.read(readingStatsRepositoryProvider).recordActivity();
        ref.invalidate(gamificationProvider);
      } catch (e) {
        debugPrint('Error al registrar actividad: $e');
      }
      ref.invalidate(journalProvider(JournalType.manga));
      ref.invalidate(journalEntryProvider((JournalType.manga, _manga.idManga ?? 0)));
      if (mounted) _showSuccessSnack('Progreso actualizado');
    } catch (e) {
      if (mounted) {
        setState(() => _currentChapterLocal = previousChapter);
        _showErrorSnack('Error al actualizar: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveTotalChapters(int totalChapters) async {
    final previousTotal = _totalChaptersLocal;
    setState(() {
      _isSaving = true;
      _totalChaptersLocal = totalChapters;
    });
    try {
      final repo = ref.read(catalogRepositoryProvider);
      final mangaToSave = MangaResponseDTO(
        idManga: _manga.idManga,
        malId: _manga.malId,
        title: _manga.title,
        author: _manga.author,
        totalChapters: totalChapters,
        coverUrl: _manga.coverUrl,
        description: _manga.description,
        genres: _manga.genres,
        publicationStatus: _manga.publicationStatus,
        demographic: _manga.demographic,
        malScore: _manga.malScore,
      );
      await repo.saveOrUpdateManga(mangaToSave);
      ref.invalidate(journalProvider(JournalType.manga));
      ref.invalidate(journalEntryProvider((JournalType.manga, _manga.idManga ?? 0)));
      if (mounted) {
        _showSuccessSnack('Total de capítulos guardado');
        _showUpdateChapterSheet(knownTotal: totalChapters);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _totalChaptersLocal = previousTotal);
        _showErrorSnack('Error al guardar capítulos: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSuccessSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_outline, color: Colors.white),
        const SizedBox(width: 8),
        Text(msg),
      ]),
      backgroundColor: AppColors.statusReading,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Theme.of(context).colorScheme.error,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _promptForTotalChapters() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => _TotalDialog(
        controller: controller,
        title: 'Falta información',
        body: 'Para hacer un seguimiento adecuado, necesitamos saber cuántos capítulos tiene este manga.',
        label: 'Total de capítulos',
        icon: Icons.menu_book_rounded,
        accent: _kMangaAccent,
        onConfirm: (val) {
          if (val != null && val > 0) {
            Navigator.pop(context);
            _saveTotalChapters(val);
          }
        },
      ),
    );
  }

  void _showUpdateChapterSheet({int? knownTotal}) {
    final total = knownTotal ?? _totalChapters;
    if (total == null || total <= 0) {
      _promptForTotalChapters();
      return;
    }
    _showProgressSheet(
      title: _manga.title,
      label: 'Capítulo actual (de $total)',
      icon: Icons.bookmark_outlined,
      currentValue: _currentChapter,
      accent: _kMangaAccent,
      isSaving: _isSaving,
      onSave: (val) {
        Navigator.pop(context);
        _updateChapter(val);
      },
    );
  }

  void _showProgressSheet({
    required String title,
    required String label,
    required IconData icon,
    required int currentValue,
    required Color accent,
    required bool isSaving,
    required void Function(int) onSave,
  }) {
    final controller = TextEditingController(text: currentValue.toString());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProgressSheet(
        title: title,
        fieldLabel: label,
        fieldIcon: icon,
        controller: controller,
        accent: accent,
        isSaving: isSaving,
        onSave: onSave,
      ),
    );
  }

  void _goToEditJournal() => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => JournalItemEditPage(
                journal: _journal, type: JournalType.manga)),
      );

  @override
  Widget build(BuildContext context) {
    final updatedJournal =
        ref.watch(journalEntryProvider((JournalType.manga, _manga.idManga ?? 0)));
    final journal = (updatedJournal as MangaJournalResponseDTO?) ?? _journal;
    final manga = journal.manga!;

    final currentChapter = _currentChapterLocal ?? journal.currentChapter ?? 0;
    final totalChapters = _totalChaptersLocal ?? manga.totalChapters;
    final progress = (totalChapters ?? 0) > 0
        ? (currentChapter / totalChapters!).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          _CoverAppBar(
            title: manga.title,
            coverUrl: manga.coverUrl,
            accent: _kMangaAccent,
            typeLabel: 'Manga',
            typeIcon: Icons.menu_book_rounded,
          ),
        ],
        body: _ProgressBody(
          accent: _kMangaAccent,
          currentProgress: currentChapter,
          totalProgress: totalChapters,
          progress: progress,
          progressLabel: 'Capítulo',
          sessionRoute: '/journal/manga/session',
          rawJournal: _journal,
          isSaving: _isSaving,
          onUpdateProgress: _showUpdateChapterSheet,
          onEditJournal: _goToEditJournal,
          statsWidget: _StatsGrid(
            accent: _kMangaAccent,
            startDate: journal.startDate,
            currentProgress: currentChapter,
            totalProgress: totalChapters,
            itemId: manga.idManga,
            progressLabel: 'Caps.',
          ),
        ),
      ),
    );
  }
}

class FanficReadingProgressPage extends ConsumerStatefulWidget {
  final FanficJournalResponseDTO journal;
  const FanficReadingProgressPage({super.key, required this.journal});

  @override
  ConsumerState<FanficReadingProgressPage> createState() =>
      _FanficReadingProgressPageState();
}

class _FanficReadingProgressPageState
    extends ConsumerState<FanficReadingProgressPage> {
  bool _isSaving = false;
  int? _currentChapterLocal;
  int? _totalChaptersLocal;

  FanficJournalResponseDTO get _journal => widget.journal;
  FanfictionResponseDTO get _fanfic => _journal.fanfic;

  int? get _totalChapters => _totalChaptersLocal ?? _fanfic.totalChapters;
  int get _currentChapter => _currentChapterLocal ?? _journal.currentChapter ?? 0;

  Future<void> _updateChapter(int newChapter) async {
    if (_isSaving) return;
    final previousChapter = _currentChapterLocal;
    setState(() {
      _isSaving = true;
      _currentChapterLocal = newChapter;
    });
    try {
      final auth = ref.read(authRepositoryProvider);
      final repo = ref.read(fanficJournalRepositoryProvider);
      final user = await auth.getUserProfile();
      final dto = FanficJournalRecordDTO(
        id: _journal.id,
        userId: user.idUser,
        fanficId: _fanfic.idFanfic ?? 0,
        ao3Id: _fanfic.ao3Id,
        status: JournalStatusHelper.mapStatusToDb(_journal.status),
        currentChapter: newChapter,
        rating: _journal.rating,
        tearDrops: _journal.tearDrops,
        spiceFlames: _journal.spiceFlames,
        personalNotes: _journal.personalNotes,
        startDate: _journal.startDate,
        endDate: _journal.endDate,
        rereading: _journal.rereading,
        mainShip: _journal.mainShip,
        secondaryShips: _journal.secondaryShips,
        angstLevel: _journal.angstLevel,
        shipLoyalty: _journal.shipLoyalty,
        canonType: _journal.canonType,
      );
      await repo.saveRaw(dto.toJson());
      try {
        await ref.read(readingStatsRepositoryProvider).recordActivity();
        ref.invalidate(gamificationProvider);
      } catch (e) {
        debugPrint('Error al registrar actividad: $e');
      }
      ref.invalidate(journalProvider(JournalType.fanfic));
      ref.invalidate(journalEntryProvider((JournalType.fanfic, _fanfic.idFanfic ?? 0)));
      if (mounted) _showSuccessSnack('Progreso actualizado');
    } catch (e) {
      if (mounted) {
        setState(() => _currentChapterLocal = previousChapter);
        _showErrorSnack('Error al actualizar: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveTotalChapters(int totalChapters) async {
    final previousTotal = _totalChaptersLocal;
    setState(() {
      _isSaving = true;
      _totalChaptersLocal = totalChapters;
    });
    try {
      final repo = ref.read(catalogRepositoryProvider);
      final fanficToSave = FanfictionResponseDTO(
        idFanfic: _fanfic.idFanfic,
        ao3Id: _fanfic.ao3Id,
        title: _fanfic.title,
        author: _fanfic.author,
        sourceMaterial: _fanfic.sourceMaterial,
        totalChapters: totalChapters,
        coverUrl: _fanfic.coverUrl,
        description: _fanfic.description,
        publicationStatus: _fanfic.publicationStatus,
        mainShip: _fanfic.mainShip,
        theme: _fanfic.theme,
        tags: _fanfic.tags,
      );
      await repo.saveOrUpdateFanfic(fanficToSave);
      ref.invalidate(journalProvider(JournalType.fanfic));
      ref.invalidate(journalEntryProvider((JournalType.fanfic, _fanfic.idFanfic ?? 0)));
      if (mounted) {
        _showSuccessSnack('Total de capítulos guardado');
        _showUpdateChapterSheet(knownTotal: totalChapters);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _totalChaptersLocal = previousTotal);
        _showErrorSnack('Error al guardar capítulos: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSuccessSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_outline, color: Colors.white),
        const SizedBox(width: 8),
        Text(msg),
      ]),
      backgroundColor: AppColors.statusReading,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Theme.of(context).colorScheme.error,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _promptForTotalChapters() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => _TotalDialog(
        controller: controller,
        title: 'Falta información',
        body: 'Para hacer un seguimiento adecuado, necesitamos saber cuántos capítulos tiene este fanfic.',
        label: 'Total de capítulos',
        icon: Icons.bookmark_outline,
        accent: _kFanficAccent,
        onConfirm: (val) {
          if (val != null && val > 0) {
            Navigator.pop(context);
            _saveTotalChapters(val);
          }
        },
      ),
    );
  }

  void _showUpdateChapterSheet({int? knownTotal}) {
    final total = knownTotal ?? _totalChapters;
    if (total == null || total <= 0) {
      _promptForTotalChapters();
      return;
    }
    _showProgressSheet(
      title: _fanfic.title,
      label: 'Capítulo actual (de $total)',
      icon: Icons.favorite_rounded,
      currentValue: _currentChapter,
      accent: _kFanficAccent,
      isSaving: _isSaving,
      onSave: (val) {
        Navigator.pop(context);
        _updateChapter(val);
      },
    );
  }

  void _showProgressSheet({
    required String title,
    required String label,
    required IconData icon,
    required int currentValue,
    required Color accent,
    required bool isSaving,
    required void Function(int) onSave,
  }) {
    final controller = TextEditingController(text: currentValue.toString());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProgressSheet(
        title: title,
        fieldLabel: label,
        fieldIcon: icon,
        controller: controller,
        accent: accent,
        isSaving: isSaving,
        onSave: onSave,
      ),
    );
  }

  void _goToEditJournal() => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => JournalItemEditPage(
                journal: _journal, type: JournalType.fanfic)),
      );

  @override
  Widget build(BuildContext context) {
    final updatedJournal =
        ref.watch(journalEntryProvider((JournalType.fanfic, _fanfic.idFanfic ?? 0)));
    final journal = (updatedJournal as FanficJournalResponseDTO?) ?? _journal;
    final fanfic = journal.fanfic;

    final currentChapter = _currentChapterLocal ?? journal.currentChapter ?? 0;
    final totalChapters = _totalChaptersLocal ?? fanfic.totalChapters;
    final progress = (totalChapters ?? 0) > 0
        ? (currentChapter / totalChapters!).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          _CoverAppBar(
            title: fanfic.title,
            coverUrl: fanfic.coverUrl,
            accent: _kFanficAccent,
            typeLabel: 'Fanfic',
            typeIcon: Icons.favorite_rounded,
          ),
        ],
        body: _ProgressBody(
          accent: _kFanficAccent,
          currentProgress: currentChapter,
          totalProgress: totalChapters,
          progress: progress,
          progressLabel: 'Capítulo',
          sessionRoute: '/journal/fanfic/session',
          rawJournal: _journal,
          isSaving: _isSaving,
          onUpdateProgress: _showUpdateChapterSheet,
          onEditJournal: _goToEditJournal,
          statsWidget: _StatsGrid(
            accent: _kFanficAccent,
            startDate: journal.startDate,
            currentProgress: currentChapter,
            totalProgress: totalChapters,
            itemId: fanfic.idFanfic,
            progressLabel: 'Caps.',
          ),
        ),
      ),
    );
  }
}

class _CoverAppBar extends StatelessWidget {
  final String title;
  final String? coverUrl;
  final Color accent;
  final String typeLabel;
  final IconData typeIcon;

  const _CoverAppBar({
    required this.title,
    required this.coverUrl,
    required this.accent,
    required this.typeLabel,
    required this.typeIcon,
  });

  @override
  Widget build(BuildContext context) {
    final hasCover = coverUrl != null && coverUrl!.isNotEmpty;

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: accent,
      foregroundColor: Colors.white,
      title: Row(
        children: [
          Icon(typeIcon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (hasCover)
              CachedNetworkImage(
                imageUrl: coverUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: accent),
                errorWidget: (_, _, _) => Container(color: accent),
              )
            else
              Container(color: accent),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(width: 20),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 70,
                        height: 100,
                        child: hasCover
                            ? CachedNetworkImage(
                                imageUrl: coverUrl!,
                                fit: BoxFit.cover,
                                placeholder: (_, _) =>
                                    Container(color: Colors.white12),
                                errorWidget: (_, _, _) => Container(
                                  color: Colors.white12,
                                  child: Icon(typeIcon,
                                      color: Colors.white54, size: 28),
                                ),
                              )
                            : Container(
                                color: Colors.white12,
                                child: Icon(typeIcon,
                                    color: Colors.white54, size: 28),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(typeIcon, size: 10, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                typeLabel.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  final Color accent;
  final int currentProgress;
  final int? totalProgress;
  final double progress;
  final String progressLabel;
  final String sessionRoute;
  final dynamic rawJournal;
  final bool isSaving;
  final VoidCallback onUpdateProgress;
  final VoidCallback onEditJournal;
  final Widget statsWidget;

  const _ProgressBody({
    required this.accent,
    required this.currentProgress,
    required this.totalProgress,
    required this.progress,
    required this.progressLabel,
    required this.sessionRoute,
    required this.rawJournal,
    required this.isSaving,
    required this.onUpdateProgress,
    required this.onEditJournal,
    required this.statsWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final percentage = (progress * 100).toStringAsFixed(1);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 170,
                  height: 170,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 13,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            accent.withValues(alpha: 0.1)),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 1100),
                        curve: Curves.easeOutCubic,
                        builder: (_, val, _) => CircularProgressIndicator(
                          value: val,
                          strokeWidth: 13,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(accent),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$percentage%',
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: accent,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              totalProgress != null && totalProgress! > 0
                                  ? '$currentProgress / $totalProgress'
                                  : '$progressLabel $currentProgress',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: accent.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(accent),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$progressLabel $currentProgress',
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                          if (totalProgress != null)
                            Text(
                              'de $totalProgress',
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          statsWidget,
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: onUpdateProgress,
            icon: isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.edit_note_rounded),
            label: Text('Actualizar $progressLabel'.toLowerCase()),
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () =>
                GoRouter.of(context).push(sessionRoute, extra: rawJournal),
            icon: const Icon(Icons.timer_outlined),
            label: const Text('Iniciar sesión de lectura'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.surface(context),
              foregroundColor: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onEditJournal,
            icon: const Icon(Icons.tune_rounded),
            label: const Text('Editar journal completo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: accent,
              side: BorderSide(color: accent.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends ConsumerWidget {
  final Color accent;
  final String? startDate;
  final int currentProgress;
  final int? totalProgress;
  final int? itemId;
  final String progressLabel;

  const _StatsGrid({
    required this.accent,
    required this.startDate,
    required this.currentProgress,
    required this.totalProgress,
    required this.itemId,
    required this.progressLabel,
  });

  String _formatDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int? days;
    if (startDate != null && startDate!.isNotEmpty) {
      try {
        days = DateTime.now().difference(DateTime.parse(startDate!)).inDays + 1;
      } catch (_) {}
    }
    final remaining = totalProgress != null
        ? (totalProgress! - currentProgress).clamp(0, totalProgress!)
        : null;

    final statsParams = ItemStatsParams(
      itemId: itemId,
      remainingPages: remaining ?? 0,
    );
    final statsAsync = ref.watch(itemReadingStatsProvider(statsParams));

    final stats = <_StatItem>[
      if (days != null)
        _StatItem(Icons.calendar_today_outlined, 'Días leyendo', '$days'),
      if (startDate != null && startDate!.isNotEmpty)
        _StatItem(Icons.play_circle_outline, 'Inicio', _formatDate(startDate!)),
      _StatItem(Icons.bookmark_added_outlined, '$progressLabel leídos',
          '$currentProgress'),
      if (remaining != null)
        _StatItem(Icons.library_books_outlined, '$progressLabel restantes',
            '$remaining'),
    ];

    final statsData = statsAsync.value;
    final totalTimeSecs = statsData?['totalDurationSeconds'] as int?;
    if (totalTimeSecs != null && totalTimeSecs > 0) {
      final th = totalTimeSecs ~/ 3600;
      final tm = (totalTimeSecs % 3600) ~/ 60;
      stats.add(_StatItem(Icons.timelapse_rounded, 'Tiempo invertido',
          th > 0 ? '${th}h ${tm}m' : '${tm}m'));
    }
    final speed = statsData?['speedPagesPerHour'] as double?;
    if (speed != null && speed > 0 && speed != 30.0) {
      stats.add(_StatItem(
          Icons.speed_rounded, 'Velocidad', '${speed.toStringAsFixed(1)}/h'));
      final remainingSecs =
          statsData?['estimatedTimeRemainingSeconds'] as int?;
      if (remainingSecs != null && remainingSecs > 0) {
        final h = remainingSecs ~/ 3600;
        final m = (remainingSecs % 3600) ~/ 60;
        stats.add(_StatItem(Icons.timer_outlined, 'Tiempo est.',
            h > 0 ? '${h}h ${m}m' : '${m}m'));
      }
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: stats.length,
      itemBuilder: (context, i) =>
          _StatCard(stat: stats[i], accent: accent),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  const _StatItem(this.icon, this.label, this.value);
}

class _StatCard extends StatelessWidget {
  final _StatItem stat;
  final Color accent;
  const _StatCard({required this.stat, required this.accent});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(stat.icon, size: 14, color: accent),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  stat.label,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary(context),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            stat.value,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSheet extends StatelessWidget {
  final String title;
  final String fieldLabel;
  final IconData fieldIcon;
  final TextEditingController controller;
  final Color accent;
  final bool isSaving;
  final void Function(int) onSave;

  const _ProgressSheet({
    required this.title,
    required this.fieldLabel,
    required this.fieldIcon,
    required this.controller,
    required this.accent,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Actualizar progreso',
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  )),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: fieldLabel,
                  prefixIcon: Icon(fieldIcon, color: accent, size: 20),
                  filled: true,
                  fillColor: AppColors.card(context),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: AppColors.border(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accent, width: 1.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  floatingLabelStyle: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isSaving
                      ? null
                      : () {
                          final val = int.tryParse(controller.text);
                          if (val != null && val >= 0) onSave(val);
                        },
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_rounded),
                  label: const Text('Guardar progreso'),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalDialog extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final String body;
  final String label;
  final IconData icon;
  final Color accent;
  final void Function(int?) onConfirm;

  const _TotalDialog({
    required this.controller,
    required this.title,
    required this.body,
    required this.label,
    required this.icon,
    required this.accent,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(body,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary(context),
                  )),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: accent, width: 1.5),
              ),
              prefixIcon: Icon(icon, color: accent),
              floatingLabelStyle: TextStyle(color: accent),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => onConfirm(int.tryParse(controller.text)),
          style: FilledButton.styleFrom(backgroundColor: accent),
          child: const Text('Guardar y continuar'),
        ),
      ],
    );
  }
}
