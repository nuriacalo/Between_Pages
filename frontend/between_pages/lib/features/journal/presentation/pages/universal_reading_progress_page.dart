import 'package:between_pages/core/theme/app_colors.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/catalog/application/repositories/book_search_repository.dart';
import 'package:between_pages/features/catalog/application/repositories/manga_search_repository.dart';
import 'package:between_pages/features/catalog/application/repositories/fanfic_search_repository.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/auth/application/repositories/auth_repository.dart';
import 'package:between_pages/features/catalog/presentation/pages/item_reading_stats_provider.dart';
import 'package:between_pages/features/journal/domain/responses/base_journal_response_dto.dart';
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
import 'package:between_pages/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ------------------- Configuración de acentos por tipo -------------------
const _kBookAccent = AppColors.colorLibro;
const _kMangaAccent = AppColors.colorManga;
const _kFanficAccent = AppColors.colorFanfic;

// ------------------- Página de progreso unificada -----------------------
/// Página única para mostrar el progreso de lectura de cualquier formato.
/// Accepta un journal de tipo [T] que puede ser BookJournalResponseDto,
/// MangaJournalResponseDTO o FanficJournalResponseDTO.
class ReadingProgressPage<T extends BaseJournalResponseDTO>
    extends ConsumerStatefulWidget {
  final T journal;
  final JournalType type;
  const ReadingProgressPage({
    super.key,
    required this.journal,
    required this.type,
  });

  @override
  ConsumerState<ReadingProgressPage> createState() =>
      _ReadingProgressPageState<T>();
}

class _ReadingProgressPageState<T extends BaseJournalResponseDTO>
    extends ConsumerState<ReadingProgressPage<T>> {
  bool _isSaving = false;
  int? _currentLocal;
  int? _totalLocal;

  // Métodos auxiliares que usan el journal actualizado
  String _getTitle(dynamic journal) {
    switch (widget.type) {
      case JournalType.book:
        return (journal as BookJournalResponseDto).book.title;
      case JournalType.manga:
        return (journal as MangaJournalResponseDTO).manga?.title ?? 'Sin título';
      case JournalType.fanfic:
        return (journal as FanficJournalResponseDTO).fanfic.title ?? 'Sin título';
    }
  }

  String? _getCoverUrl(dynamic journal) {
    switch (widget.type) {
      case JournalType.book:
        return (journal as BookJournalResponseDto).book.coverUrl;
      case JournalType.manga:
        return (journal as MangaJournalResponseDTO).manga?.coverUrl;
      case JournalType.fanfic:
        return (journal as FanficJournalResponseDTO).fanfic.coverUrl;
    }
  }

  int _getCurrent(dynamic journal) {
    return _currentLocal ?? _getCurrentFromJournal(journal);
  }

  int? _getTotal(dynamic journal) {
    return _totalLocal ?? _getTotalFromJournal(journal);
  }

  String _progressLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (widget.type) {
      case JournalType.book:
        return l10n.pages;
      case JournalType.manga:
        return l10n.chapters;
      case JournalType.fanfic:
        return l10n.chapters;
    }
  }

  IconData get _typeIcon {
    switch (widget.type) {
      case JournalType.book:
        return Icons.book_rounded;
      case JournalType.manga:
        return Icons.menu_book_rounded;
      case JournalType.fanfic:
        return Icons.favorite_rounded;
    }
  }

  String _typeLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (widget.type) {
      case JournalType.book:
        return l10n.books;
      case JournalType.manga:
        return l10n.mangas;
      case JournalType.fanfic:
        return l10n.fanfics;
    }
  }

  Color get _accent {
    switch (widget.type) {
      case JournalType.book:
        return _kBookAccent;
      case JournalType.manga:
        return _kMangaAccent;
      case JournalType.fanfic:
        return _kFanficAccent;
    }
  }

  String get _sessionRoute {
    switch (widget.type) {
      case JournalType.book:
        return '/journal/book/session';
      case JournalType.manga:
        return '/journal/manga/session';
      case JournalType.fanfic:
        return '/journal/fanfic/session';
    }
  }

  String get _itemTypeString {
    switch (widget.type) {
      case JournalType.book:
        return 'BOOK';
      case JournalType.manga:
        return 'MANGA';
      case JournalType.fanfic:
        return 'FANFIC';
    }
  }

  int _getId() {
    switch (widget.type) {
      case JournalType.book:
        return (widget.journal as BookJournalResponseDto).book.idBook ?? 0;
      case JournalType.manga:
        return (widget.journal as MangaJournalResponseDTO).manga!.idManga ?? 0;
      case JournalType.fanfic:
        return (widget.journal as FanficJournalResponseDTO).fanfic.idFanfic ??
            0;
    }
  }

  // ----------------------------------------------------------------------
  // Lógica de actualización de progreso
  // ----------------------------------------------------------------------
  Future<void> _updateProgress(dynamic journal, int newValue) async {
    if (_isSaving) return;
    final previous = _currentLocal;
    setState(() => _isSaving = true);
    _currentLocal = newValue;
    try {
      final auth = ref.read(authRepositoryProvider);
      final user = await auth.getUserProfile();
      switch (widget.type) {
        case JournalType.book:
          final j = journal as BookJournalResponseDto;
          final repo = ref.read(bookJournalRepositoryProvider);
          final dto = BookJournalRecordDTO(
            id: j.id,
            userId: user.idUser,
            bookId: j.book.idBook ?? 0,
            googleBooksId: j.book.googleBooksId?.isNotEmpty == true
                ? j.book.googleBooksId
                : null,
            status: JournalStatusHelper.mapStatusToDb(j.status),
            currentPage: newValue,
            rating: j.rating,
            tearDrops: j.tearDrops,
            spiceFlames: j.spiceFlames,
            readingFormat: j.readingFormat,
            emotions: j.emotions,
            favoriteQuotes: j.favoriteQuotes,
            personalNotes: j.personalNotes,
            startDate: j.startDate,
            endDate: j.endDate,
            ownership: j.ownership,
          );
          await repo.saveRaw(dto.toJson());
          break;
        case JournalType.manga:
          final j = journal as MangaJournalResponseDTO;
          final repo = ref.read(mangaJournalRepositoryProvider);
          final dto = MangaJournalRecordDTO(
            id: j.id,
            userId: user.idUser,
            mangaId: j.manga!.idManga,
            malId: j.manga!.malId,
            status: JournalStatusHelper.mapStatusToDb(j.status),
            currentChapter: newValue,
            currentVolume: j.currentVolume,
            rating: j.rating,
            tearDrops: j.tearDrops,
            spiceFlames: j.spiceFlames,
            readingFormat: j.readingFormat,
            favoriteCharacter: j.favoriteCharacter,
            favoriteArc: j.favoriteArc,
            personalNotes: j.personalNotes,
            startDate: j.startDate,
            endDate: j.endDate,
            ownership: j.ownership,
            rereading: j.rereading,
          );
          await repo.saveRaw(dto.toJson());
          break;
        case JournalType.fanfic:
          final j = journal as FanficJournalResponseDTO;
          final repo = ref.read(fanficJournalRepositoryProvider);
          final dto = FanficJournalRecordDTO(
            id: j.id,
            userId: user.idUser,
            fanficId: j.fanfic.idFanfic ?? 0,
            ao3Id: j.fanfic.ao3Id,
            status: JournalStatusHelper.mapStatusToDb(j.status),
            currentChapter: newValue,
            rating: j.rating,
            tearDrops: j.tearDrops,
            spiceFlames: j.spiceFlames,
            personalNotes: j.personalNotes,
            startDate: j.startDate,
            endDate: j.endDate,
            rereading: j.rereading,
          );
          await repo.saveRaw(dto.toJson());
          break;
      }
      try {
        await ref.read(readingStatsRepositoryProvider).recordActivity();
        ref.invalidate(gamificationProvider);

      } catch (_) {}

      // Ahora invalidamos lo mínimo necesario para recalcular el entry mostrado.
      ref.invalidate(journalProvider(widget.type));
      ref.invalidate(journalEntryProvider((widget.type, _getId())));



      if (mounted) _showSuccessSnack('Progreso actualizado');
    } catch (e) {
      if (mounted) {
        setState(() => _currentLocal = previous);
        _showErrorSnack('Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveTotal(dynamic journal, int total) async {
    final previousTotal = _totalLocal;
    setState(() => _isSaving = true);
    _totalLocal = total;
    try {
      switch (widget.type) {
        case JournalType.book:
          final book = (journal as BookJournalResponseDto).book;
          final updatedBook = BookResponseDTO(
            idBook: book.idBook,
            googleBooksId: book.googleBooksId,
            title: book.title,
            author: book.author,
            pageCount: total,
            coverUrl: book.coverUrl,
            isbn: book.isbn,
            publisher: book.publisher,
            publishYear: book.publishYear,
            description: book.description,
            genres: book.genres,
            bookType: book.bookType,
          );
          await ref.read(bookSearchRepositoryProvider).saveOrUpdateBook(updatedBook);
          break;
        case JournalType.manga:
          final manga = (journal as MangaJournalResponseDTO).manga!;
          final updatedManga = MangaResponseDTO(
            idManga: manga.idManga,
            malId: manga.malId,
            title: manga.title,
            author: manga.author,
            totalChapters: total,
            coverUrl: manga.coverUrl,
            description: manga.description,
            genres: manga.genres,
            publicationStatus: manga.publicationStatus,
            demographic: manga.demographic,
            malScore: manga.malScore,
          );
          await ref.read(mangaSearchRepositoryProvider).saveOrUpdateManga(updatedManga);
          break;
        case JournalType.fanfic:
          final fanfic = (journal as FanficJournalResponseDTO).fanfic;
          final updatedFanfic = FanfictionResponseDTO(
            idFanfic: fanfic.idFanfic,
            ao3Id: fanfic.ao3Id,
            title: fanfic.title,
            author: fanfic.author,
            sourceMaterial: fanfic.sourceMaterial,
            totalChapters: total,
            coverUrl: fanfic.coverUrl,
            description: fanfic.description,
            publicationStatus: fanfic.publicationStatus,
            mainShip: fanfic.mainShip,
            theme: fanfic.theme,
            tags: fanfic.tags,
            genres: fanfic.genres,
          );
          await ref.read(fanficSearchRepositoryProvider).saveOrUpdateFanfic(updatedFanfic);
          break;
      }
      ref.invalidate(journalProvider(widget.type));
      ref.invalidate(journalEntryProvider((widget.type, _getId())));
      if (mounted) {
        _showSuccessSnack(AppLocalizations.of(context)!.totalSaved);
        _showUpdateSheet(journal, _getCurrent(journal), total);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _totalLocal = previousTotal);
        _showErrorSnack('${AppLocalizations.of(context)!.errorPrefix}: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSuccessSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(msg),
          ],
        ),
        backgroundColor: AppColors.statusReading,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _promptForTotal(dynamic journal) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final pLabel = _progressLabel(context);
    showDialog(
      context: context,
      builder: (_) => _TotalDialog(
        controller: controller,
        title: l10n.totalOfItem(pLabel),
        accent: _accent,
        body: l10n.accurateTrackingReason(pLabel),
        label: l10n.totalOfItem(pLabel),
        icon: _typeIcon,
        onConfirm: (val) {
          if (val != null && val > 0) {
            Navigator.pop(context);
            _saveTotal(journal, val);
          }
        },
      ),
    );
  }

  void _showUpdateSheet(dynamic journal, int current, int? total) {
    final l10n = AppLocalizations.of(context)!;
    if (total == null || total <= 0) {
      _promptForTotal(journal);
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProgressSheet(
        title: _getTitle(journal),
        fieldLabel: l10n.currentOfTotal(_progressLabel(context), total.toString()),
        fieldIcon: _typeIcon,
        controller: TextEditingController(text: current.toString()),
        accent: _accent,
        isSaving: _isSaving,
        maxValue: total,
        onSave: (val) {
          Navigator.pop(context);
          _updateProgress(journal, val);
        },
      ),
    );
  }

  void _goToEditJournal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            JournalItemEditPage(journal: widget.journal, type: widget.type),
      ),
    );
  }

  String? _getStartDate(dynamic journal) {
    switch (widget.type) {
      case JournalType.book:
        return (journal as BookJournalResponseDto).startDate;
      case JournalType.manga:
        return (journal as MangaJournalResponseDTO).startDate;
      case JournalType.fanfic:
        return (journal as FanficJournalResponseDTO).startDate;
    }
  }

  // ----------------------------------------------------------------------
  // Build
  // ----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final updatedJournal = ref.watch(
      journalEntryProvider((widget.type, _getId())),
    );
    final journal = updatedJournal ?? widget.journal;
    final current = _getCurrent(journal);
    final total = _getTotal(journal);
    final progress = (total != null && total > 0)
        ? (current / total).clamp(0.0, 1.0)
        : 0.0;

    final String pLabel = _progressLabel(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          _CoverAppBar(
            title: _getTitle(journal),
            coverUrl: _getCoverUrl(journal),
            accent: _accent,
            typeLabel: _typeLabel(context),
            typeIcon: _typeIcon,
          ),
        ],
        body: _ProgressBody(
          accent: _accent,
          currentProgress: current,
          totalProgress: total,
          progress: progress,
          progressLabel: pLabel,
          sessionRoute: _sessionRoute,
          rawJournal: journal,
          isSaving: _isSaving,
          onUpdateProgress: () => _showUpdateSheet(journal, current, total),
          onEditJournal: _goToEditJournal,
          statsWidget: _StatsGrid(
            accent: _accent,
            startDate: _getStartDate(journal),
            currentProgress: current,
            totalProgress: total,
            itemId: _getId(),
            progressLabel: pLabel,
            itemType: _itemTypeString,
          ),
        ),
      ),
    );
  }

  int _getCurrentFromJournal(dynamic j) {
    switch (widget.type) {
      case JournalType.book:
        return (j as BookJournalResponseDto).currentPage ?? 0;
      case JournalType.manga:
        return (j as MangaJournalResponseDTO).currentChapter ?? 0;
      case JournalType.fanfic:
        return (j as FanficJournalResponseDTO).currentChapter ?? 0;
    }
  }

  int? _getTotalFromJournal(dynamic j) {
    switch (widget.type) {
      case JournalType.book:
        return (j as BookJournalResponseDto).book.pageCount;
      case JournalType.manga:
        return (j as MangaJournalResponseDTO).manga!.totalChapters;
      case JournalType.fanfic:
        return (j as FanficJournalResponseDTO).fanfic.totalChapters;
    }
  }
}

// ------------------- Componentes visuales ------------------
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
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: accent,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (hasCover)
              CachedNetworkImage(
                imageUrl: coverUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: accent),
                errorWidget: (_, _, _) => Container(color: accent),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.80),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 72,
                        height: 104,
                        child: hasCover
                            ? CachedNetworkImage(
                                imageUrl: coverUrl!,
                                fit: BoxFit.cover,
                                placeholder: (_, _) =>
                                    Container(color: Colors.white12),
                                errorWidget: (_, _, _) => Container(
                                  color: Colors.white12,
                                  child: Icon(
                                    typeIcon,
                                    color: Colors.white54,
                                    size: 28,
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.white12,
                                child: Icon(
                                  typeIcon,
                                  color: Colors.white54,
                                  size: 28,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(8),
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
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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

  String _milestoneMessage(double p, AppLocalizations l10n) {
    if (p >= 1.0) return l10n.milestoneCompleted;
    if (p >= 0.75) return l10n.milestoneAlmostThere;
    if (p >= 0.5) return l10n.milestoneHalfway;
    if (p >= 0.25) return l10n.milestoneGoodStart;
    if (p > 0) return l10n.milestoneJustStarted;
    return l10n.milestoneNotStarted;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Círculo de progreso
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 190,
                  height: 190,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 10,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          accent.withValues(alpha: 0.1),
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOutCubic,
                        builder: (_, val, _) => CircularProgressIndicator(
                          value: val,
                          strokeWidth: 10,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(accent),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: progress * 100),
                              duration: const Duration(milliseconds: 1200),
                              curve: Curves.easeOutCubic,
                              builder: (_, val, _) => Text(
                                '${val.round()}%',
                                style: textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: accent,
                                  fontSize: 32,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              totalProgress != null && totalProgress! > 0
                                  ? '$currentProgress / $totalProgress'
                                  : '$progressLabel $currentProgress',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary(context),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _milestoneMessage(progress, l10n),
                    style: textTheme.labelMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: accent.withValues(alpha: 0.1),
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
                              fontSize: 10,
                            ),
                          ),
                          if (totalProgress != null)
                            Text(
                                l10n.outOf(totalProgress.toString()),
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary(context),
                                fontSize: 10,
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
          // Botones
          ElevatedButton.icon(
            onPressed: onUpdateProgress,
            icon: const Icon(Icons.edit_note_rounded, size: 18),
            label: Text(l10n.updateItem(progressLabel)),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 3,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () =>
                GoRouter.of(context).push(sessionRoute, extra: rawJournal),
            icon: Icon(Icons.timer_outlined, color: accent, size: 18),
            label: Text(
              l10n.startReadingSession,
              style: TextStyle(color: AppColors.textPrimary(context)),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: BorderSide(color: AppColors.border(context)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onEditJournal,
            icon: Icon(
              Icons.tune_rounded,
              color: AppColors.textSecondary(context),
              size: 16,
            ),
            label: Text(
              l10n.editJournal,
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
            style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// _StatsGrid y auxiliares (ligeramente simplificados)
// ----------------------------------------------------------------------
class _StatsGrid extends ConsumerStatefulWidget {
  final Color accent;
  final String? startDate;
  final int currentProgress;
  final int? totalProgress;
  final int? itemId;
  final String progressLabel;
  final String itemType;
  const _StatsGrid({
    required this.accent,
    required this.startDate,
    required this.currentProgress,
    required this.totalProgress,
    required this.itemId,
    required this.progressLabel,
    required this.itemType,
  });

  @override
  ConsumerState<_StatsGrid> createState() => _StatsGridState();
}

class _StatsGridState extends ConsumerState<_StatsGrid> {
  String _formatDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(
      itemReadingStatsProvider(
        ItemStatsParams(
          itemId: widget.itemId,
          remainingPages: (widget.totalProgress ?? 0) - widget.currentProgress,
          itemType: widget.itemType,
        ),
      ),
    );
    final days = (widget.startDate != null && widget.startDate!.isNotEmpty)
        ? DateTime.now().difference(DateTime.parse(widget.startDate!)).inDays +
              1
        : null;
    final remaining = widget.totalProgress != null
        ? (widget.totalProgress! - widget.currentProgress).clamp(
            0,
            widget.totalProgress!,
          )
        : null;
    final baseStats = <_StatItem>[
      if (days != null)
        _StatItem(Icons.calendar_today_outlined, l10n.daysReading, l10n.daysCount(days)),
      if (widget.startDate != null && widget.startDate!.isNotEmpty)
        _StatItem(
          Icons.play_circle_outline,
          l10n.startedOn,
          _formatDate(widget.startDate!),
        ),
      _StatItem(
        Icons.bookmark_added_outlined,
        l10n.itemsRead(widget.progressLabel),
        '${widget.currentProgress}',
      ),
      if (remaining != null)
        _StatItem(Icons.library_books_outlined, l10n.itemsRemaining, '$remaining'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: widget.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.yourProgress,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        statsAsync.when(
          data: (statsData) {
            final totalTimeSecs = statsData['totalDurationSeconds'] as int?;
            final allStats = <_StatItem>[...baseStats];
            if (totalTimeSecs != null && totalTimeSecs > 0) {
              final th = totalTimeSecs ~/ 3600;
              final tm = (totalTimeSecs % 3600) ~/ 60;
              allStats.add(
                _StatItem(
                  Icons.timelapse_rounded,
                  l10n.totalTime,
                  th > 0 ? l10n.hoursMinutes(th, tm) : l10n.minutes(tm),
                ),
              );
            }
            return _buildGrid(context, allStats);
          },
          loading: () => _buildGrid(context, baseStats, isLoading: true),
          error: (_, _) => _buildGrid(context, baseStats, hasError: true),
        ),
      ],
    );
  }

  Widget _buildGrid(
    BuildContext context,
    List<_StatItem> items, {
    bool isLoading = false,
    bool hasError = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    if (hasError) {
      return Center(
        child: Text(
          l10n.errorLoadingStats,
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
      );
    }
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => isLoading
              ? _StatCardSkeleton()
              : _StatCard(stat: items[i], accent: widget.accent),
        );
      },
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
    return AnimatedScale(
      scale: 0.95,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.6),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(stat.icon, size: 12, color: accent),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            stat.label,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.textSecondary(context),
                                  fontSize: 10,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      stat.value,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Container(width: 4, color: Colors.grey.shade300),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 60, height: 10, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Container(width: 40, height: 14, color: Colors.grey.shade300),
                ],
              ),
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
  final int maxValue;
  final void Function(int) onSave;
  const _ProgressSheet({
    required this.title,
    required this.fieldLabel,
    required this.fieldIcon,
    required this.controller,
    required this.accent,
    required this.isSaving,
    required this.maxValue,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
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
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(fieldIcon, color: accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.updateProgress,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        Text(
                          title,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofocus: true,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  labelText: fieldLabel,
                  labelStyle: TextStyle(
                    color: AppColors.textSecondary(context),
                  ),
                  floatingLabelStyle: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: Icon(fieldIcon, color: accent),
                  filled: true,
                  fillColor: AppColors.card(context),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.border(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: accent, width: 1.8),
                  ),
                ),
                onSubmitted: (value) {
                  final val = int.tryParse(value);
                  if (val != null && val >= 0 && val <= maxValue) {
                    onSave(val);
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () {
                        final val = int.tryParse(controller.text);
                        if (val != null && val >= 0 && val <= maxValue) {
                          onSave(val);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(l10n.saveProgress),
                        ],
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
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      backgroundColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accent.withValues(alpha: 0.15)),
            ),
            child: Text(
              body,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary(context),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autofocus: true,
            decoration: InputDecoration(
              labelText: label,
              floatingLabelStyle: TextStyle(color: accent),
              prefixIcon: Icon(icon, color: accent),
              filled: true,
              fillColor: AppColors.card(context),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: accent, width: 1.5),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.cancelButton,
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
        ),
        FilledButton(
          onPressed: () => onConfirm(int.tryParse(controller.text)),
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(l10n.saveButton),
        ),
      ],
    );
  }
}
