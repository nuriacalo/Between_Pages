import 'dart:ui';

import 'package:between_pages/core/theme/app_colors.dart';
import 'package:between_pages/features/catalog/application/repositories/book_search_repository.dart';
import 'package:between_pages/features/catalog/application/repositories/fanfic_search_repository.dart';
import 'package:between_pages/features/catalog/application/repositories/user_catalog_repository.dart';
import 'package:between_pages/features/catalog/application/providers/all_books_provider.dart';
import 'package:between_pages/features/catalog/application/providers/all_manga_provider.dart';
import 'package:between_pages/features/catalog/application/providers/all_fanfics_provider.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/enriched_catalog_item.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/catalog/presentation/pages/book_edit_page.dart';
import 'package:between_pages/features/catalog/presentation/pages/fanfic_edit_page.dart';
import 'package:between_pages/features/catalog/presentation/pages/manga_edit_page.dart';
import 'package:between_pages/features/catalog/presentation/widgets/ownership_badge.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/domain/manga_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/records/book_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/records/fanfic_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/responses/base_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/book_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/fanfic_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/manga_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/utils/journal_status_extensions.dart';
import 'package:between_pages/features/lists/application/providers/list_provider.dart';
import 'package:between_pages/features/lists/application/repositories/reading_list_repository.dart';
import 'package:between_pages/features/lists/domain/list_response_dto.dart';
import 'package:between_pages/features/profile/application/providers/user_provider.dart';
import 'package:between_pages/features/profile/application/repositories/reading_stats_repository.dart';
import 'package:between_pages/features/profile/application/providers/gamification_provider.dart';
import 'package:between_pages/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum CatalogItemType { book, manga, fanfic }

class UnifiedCatalogData {
  final String title;
  final String author;
  final String? coverUrl;
  final String? description;
  final List<String> genres;
  final int? totalChapters;
  final String? publicationStatus;
  final String? demographic;
  final double? malScore;
  final String? mainShip;
  final String? theme;
  final int? pageCount;
  final int? publishYear;
  final String? publisher;

  const UnifiedCatalogData({
    required this.title,
    required this.author,
    this.coverUrl,
    this.description,
    this.genres = const [],
    this.totalChapters,
    this.publicationStatus,
    this.demographic,
    this.malScore,
    this.mainShip,
    this.theme,
    this.pageCount,
    this.publishYear,
    this.publisher,
  });
}

class CatalogDetailPage extends ConsumerStatefulWidget {
  final dynamic item; // Can be BookResponseDTO, MangaResponseDTO, or EnrichedCatalogItem
  final CatalogItemType type;

  const CatalogDetailPage({super.key, required this.item, required this.type});

  @override
  ConsumerState<CatalogDetailPage> createState() => _CatalogDetailPageState();
}

class _CatalogDetailPageState extends ConsumerState<CatalogDetailPage> {
  bool _isAdding = false;
  late dynamic _currentItem;
  BaseJournalResponseDTO? _journal;

  @override
  void initState() {
    super.initState();
    if (widget.item is EnrichedCatalogItem) {
      _currentItem = (widget.item as EnrichedCatalogItem).item;
      _journal = (widget.item as EnrichedCatalogItem).journal;
    } else {
      _currentItem = widget.item;
      _journal = null; // Will be fetched by _getExistingJournal
    }
  }

  // ── Derived data ──────────────────────────────────────────────────────────

  UnifiedCatalogData get _data {
    switch (widget.type) {
      case CatalogItemType.book:
        final b = _currentItem as BookResponseDTO;
        return UnifiedCatalogData(
          title: b.title,
          author: b.author,
          coverUrl: b.coverUrl,
          description: b.description,
          genres: b.genres,
          pageCount: b.pageCount,
          publishYear: b.publishYear,
          publisher: b.publisher,
        );
      case CatalogItemType.manga:
        final m = _currentItem as MangaResponseDTO;
        return UnifiedCatalogData(
          title: m.title ?? 'Sin título',
          author: m.author ?? 'Autor desconocido',
          coverUrl: m.coverUrl,
          description: m.description,
          genres: m.genres,
          totalChapters: m.totalChapters,
          publicationStatus: m.publicationStatus,
          demographic: m.demographic,
          malScore: m.malScore,
        );
      case CatalogItemType.fanfic:
        final f = _currentItem as FanfictionResponseDTO;
        return UnifiedCatalogData(
          title: f.title ?? 'Sin título',
          author: f.author ?? 'Autor desconocido',
          coverUrl: f.coverUrl,
          description: f.description,
          genres: f.genres,
          totalChapters: f.totalChapters,
          publicationStatus: f.publicationStatus,
          mainShip: f.mainShip,
          theme: f.theme,
        );
    }
  }

  Color get _typeColor => switch (widget.type) {
    CatalogItemType.book => AppColors.colorLibro,
    CatalogItemType.manga => AppColors.colorManga,
    CatalogItemType.fanfic => AppColors.colorFanfic,
  };

  IconData get _typeIcon => switch (widget.type) {
    CatalogItemType.book => Icons.book_rounded,
    CatalogItemType.manga => Icons.menu_book_rounded,
    CatalogItemType.fanfic => Icons.favorite_rounded,
  };

  String get _typeLabel => switch (widget.type) {
    CatalogItemType.book => 'Libro',
    CatalogItemType.manga => 'Manga',
    CatalogItemType.fanfic => 'Fanfic',
  };

  // ── Journal helpers ───────────────────────────────────────────────────────

  BaseJournalResponseDTO? _getExistingJournal() {
    BaseJournalResponseDTO? providerJournal;
    
    switch (widget.type) {
      case CatalogItemType.book:
        final b = _currentItem as BookResponseDTO;
        providerJournal = ref.watch(
          journalEntryProvider((JournalType.book, b.idBook ?? 0)),
        );
        break;
      case CatalogItemType.manga:
        final m = _currentItem as MangaResponseDTO;
        providerJournal = ref.watch(
          journalEntryProvider((JournalType.manga, m.idManga ?? 0)),
        );
        break;
      case CatalogItemType.fanfic:
        final f = _currentItem as FanfictionResponseDTO;
        providerJournal = ref.watch(
          journalEntryProvider((JournalType.fanfic, f.idFanfic ?? 0)),
        );
        break;
    }

    // Si el provider tiene datos frescos los usamos. Si es nulo, usamos el inicial de respaldo.
    return providerJournal ?? _journal;
  }

  void _invalidateJournals() {
    ref.invalidate(allJournalsProvider);
  }

  Future<void> _addToLibrary(String status) async {
    if (_isAdding) return;
    setState(() => _isAdding = true);

    try {
      final user = await ref.read(userProfileProvider.future);
      final userId = user.idUser;
      final isJournalStatus = status == 'READING' || status == 'FINISHED' || status == 'PAUSED' || status == 'DROPPED';

      if (isJournalStatus) {
        // --- LOGICA ANTIGUA: Crear o actualizar un Journal ---
        switch (widget.type) {
          case CatalogItemType.book:
            var book = _currentItem as BookResponseDTO;
            if ((book.idBook ?? 0) == 0) {
              book = await ref.read(bookSearchRepositoryProvider).saveOrUpdateBook(book);
              if (mounted) setState(() => _currentItem = book);
            }
            await ref.read(bookJournalRepositoryProvider).saveRaw(
              BookJournalRecordDTO(
                userId: userId,
                bookId: book.idBook ?? 0,
                googleBooksId: book.googleBooksId,
                status: status,
                currentPage: 0,
              ).toJson(),
            );
            ref.invalidate(allBooksProvider);
          case CatalogItemType.manga:
            final m = _currentItem as MangaResponseDTO;
            final mangaId = m.idManga;
            await ref.read(mangaJournalRepositoryProvider).saveRaw(
              MangaJournalRecordDTO(
                userId: userId,
                mangaId: (mangaId != null && mangaId > 0) ? mangaId : null,
                malId: m.malId,
                status: status,
                currentChapter: 0,
              ).toJson(),
            );
            ref.invalidate(allMangaProvider);
          case CatalogItemType.fanfic:
            var f = _currentItem as FanfictionResponseDTO;
            if (f.idFanfic == null || f.idFanfic == 0) {
              f = await ref.read(fanficSearchRepositoryProvider).saveOrUpdateFanfic(f);
              if (mounted) setState(() => _currentItem = f);
            }
            await ref.read(fanficJournalRepositoryProvider).saveRaw(
              FanficJournalRecordDTO(
                userId: userId,
                fanficId: f.idFanfic ?? 0,
                ao3Id: f.ao3Id,
                status: status,
                currentChapter: 0,
              ).toJson(),
            );
            ref.invalidate(allFanficsProvider);
        }
        _invalidateJournals();
        if (status == 'READING' || status == 'FINISHED') {
          await ref.read(readingStatsRepositoryProvider).recordActivity();
          ref.invalidate(gamificationProvider);
        }
      } else {
        // --- Añadir solo al catálogo ---
        final repo = ref.read(userCatalogRepositoryProvider);
        switch (widget.type) {
          case CatalogItemType.book:
            var book = _currentItem as BookResponseDTO;
            if ((book.idBook ?? 0) == 0) {
              book = await ref.read(bookSearchRepositoryProvider).saveOrUpdateBook(book);
              setState(() => _currentItem = book);
            }
            await repo.addToCatalog(userId: userId, itemType: 'BOOK', status: status, bookId: book.idBook);
            ref.invalidate(allBooksProvider);
          case CatalogItemType.manga:
            final m = _currentItem as MangaResponseDTO;
            await repo.addToCatalog(userId: userId, itemType: 'MANGA', status: status, mangaId: m.idManga);
            ref.invalidate(allMangaProvider);
          case CatalogItemType.fanfic:
            var f = _currentItem as FanfictionResponseDTO;
            if (f.idFanfic == null || f.idFanfic == 0) {
              f = await ref.read(fanficSearchRepositoryProvider).saveOrUpdateFanfic(f);
              setState(() => _currentItem = f);
            }
            await repo.addToCatalog(userId: userId, itemType: 'FANFIC', status: status, fanficId: f.idFanfic);
            ref.invalidate(allFanficsProvider);
        }
      }

      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final msg = switch (status) {
        'READING' => l10n.startedReadingItem(_data.title),
        'TBR' => l10n.addedToTbrItem(_data.title),
        'FINISHED' => l10n.finishedReadingItem(_data.title),
        _ => l10n.addedToJournalItem(_data.title),
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo actualizar la biblioteca. Inténtalo de nuevo.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _updateJournalStatus(dynamic existing, String newStatus) async {
    if (_isAdding) return;
    setState(() => _isAdding = true);
    try {
      final user = await ref.read(userProfileProvider.future);
      final userId = user.idUser;
      switch (widget.type) {
        case CatalogItemType.book:
          final j = existing as BookJournalResponseDto;
          await ref
              .read(bookJournalRepositoryProvider)
              .updateRaw(
                BookJournalRecordDTO(
                  id: j.id,
                  userId: userId,
                  bookId: j.book.idBook ?? 0,
                  googleBooksId: j.book.googleBooksId,
                  status: newStatus,
                  currentPage: j.currentPage,
                ).toJson(),
              );
        case CatalogItemType.manga:
          final j = existing as MangaJournalResponseDTO;
          await ref
              .read(mangaJournalRepositoryProvider)
              .updateRaw(
                MangaJournalRecordDTO(
                  id: j.id,
                  userId: userId,
                  mangaId: j.manga?.idManga,
                  malId: j.manga?.malId,
                  status: newStatus,
                  currentChapter: j.currentChapter,
                ).toJson(),
              );
        case CatalogItemType.fanfic:
          final j = existing as FanficJournalResponseDTO;
          await ref
              .read(fanficJournalRepositoryProvider)
              .updateRaw(
                FanficJournalRecordDTO(
                  id: j.id,
                  userId: userId,
                  fanficId: j.fanfic.idFanfic ?? 0,
                  ao3Id: j.fanfic.ao3Id,
                  status: newStatus,
                  currentChapter: j.currentChapter,
                ).toJson(),
              );
      }
      _invalidateJournals();

      // Al actualizar el estado, también registramos actividad.
      // si se empieza a leer o se marca como terminado.
      if (newStatus == 'READING' || newStatus == 'FINISHED') {
        try {
          await ref.read(readingStatsRepositoryProvider).recordActivity();
          ref.invalidate(gamificationProvider);
        } catch (e) {
          if (kDebugMode) {
            print('Error al registrar actividad: $e');
          }
        }
      }
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.statusUpdated(_data.title, newStatus.uiLabel)),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo cambiar el estado. Inténtalo de nuevo.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  Future<void> _showAddStatusDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final selectedStatus = await _showStatusPicker(
      title: l10n.addToLibrary,
      statuses: ['READING', 'TBR', 'FINISHED'],
      l10n: l10n,
    );
    if (selectedStatus != null) _addToLibrary(selectedStatus);
  }

  Future<void> _showChangeStatusDialog(dynamic existing) async {
    final l10n = AppLocalizations.of(context)!;
    final selectedStatus = await _showStatusPicker(
      title: l10n.changeStatus,
      statuses: ['READING', 'TBR', 'FINISHED', 'PAUSED', 'DROPPED'],
      l10n: l10n,
    );
    if (selectedStatus != null) _updateJournalStatus(existing, selectedStatus);
  }

  Future<String?> _showStatusPicker({
    required String title,
    required List<String> statuses,
    required AppLocalizations l10n,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    Color statusColor(String s) => switch (s) {
      'READING' => AppColors.statusReading,
      'FINISHED' => AppColors.statusFinished,
      'PAUSED' => AppColors.statusPending,
      'DROPPED' => AppColors.statusAbandoned,
      'TBR' => AppColors.statusPending,
      _ => Colors.grey,
    };

    String statusLabel(String s) => switch (s) {
      'READING' => l10n.statusReading,
      'TBR' => l10n.statusTBR,
      'FINISHED' => l10n.statusFinished,
      'PAUSED' => l10n.statusPaused,
      'DROPPED' => l10n.statusDropped,
      _ => s,
    };

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              title,
              style: Theme.of(
                ctx,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...statuses.map((s) {
              final c = statusColor(s);
              return ListTile(
                tileColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                ),
                title: Text(statusLabel(s)),
                onTap: () => Navigator.pop(ctx, s),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _openJournalEdit(dynamic journal) async {
    switch (widget.type) {
      case CatalogItemType.book:
        await context.push(
          '/journal/book/edit',
          extra: journal as BookJournalResponseDto,
        );
      case CatalogItemType.manga:
        await context.push(
          '/journal/manga/edit',
          extra: journal as MangaJournalResponseDTO,
        );
      case CatalogItemType.fanfic:
        await context.push(
          '/journal/fanfic/edit',
          extra: journal as FanficJournalResponseDTO,
        );
    }
    _invalidateJournals(); // Refresca los datos al volver
  }

  Future<void> _openItemEdit(dynamic item) async {
    dynamic updated;
    switch (widget.type) {
      case CatalogItemType.book:
        updated = await Navigator.push<BookResponseDTO>(
          context,
          MaterialPageRoute(
            builder: (_) => BookEditPage(book: item as BookResponseDTO),
          ),
        );
      case CatalogItemType.manga:
        updated = await Navigator.push<MangaResponseDTO>(
          context,
          MaterialPageRoute(
            builder: (_) => MangaEditPage(manga: item as MangaResponseDTO),
          ),
        );
      case CatalogItemType.fanfic:
        updated = await Navigator.push<FanfictionResponseDTO>(
          context,
          MaterialPageRoute(
            builder: (_) =>
                FanficEditPage(fanfic: item as FanfictionResponseDTO),
          ),
        );
    }
    if (updated != null && mounted) setState(() => _currentItem = updated);
  }

  Future<void> _showAddToListDialog() async {
    final l10n = AppLocalizations.of(context)!;

    final selectedList = await showDialog<ListResponseDTO>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addedToList),

        content: SizedBox(
          width: double.maxFinite,
          child: Consumer(
            builder: (context, dialogRef, _) {
              final lists = dialogRef.watch(listProvider);
              return lists.when(
                data: (data) {
                  if (data.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('Aún no tienes listas creadas.'),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final list = data[index];
                      return ListTile(
                        title: Text(list.name),
                        onTap: () => Navigator.of(context).pop(list),
                      );
                    },
                  );
                },
                loading: () => const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Text('Error: $error'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancelButton),
          ),
        ],
      ),
    );

    if (selectedList != null) {
      try {
        final repo = ref.read(readingListRepositoryProvider);
        int contentId;
        String contentType;

        switch (widget.type) {
          case CatalogItemType.book:
            contentId = (_currentItem as BookResponseDTO).idBook ?? 0;
            contentType = 'BOOK';
            break;
          case CatalogItemType.manga:
            contentId = (_currentItem as MangaResponseDTO).idManga!;
            contentType = 'MANGA';
            break;
          case CatalogItemType.fanfic:
            contentId = (_currentItem as FanfictionResponseDTO).idFanfic!;
            contentType = 'FANFIC';
            break;
        }

        await repo.addContentToList(selectedList.id, contentId, contentType);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_data.title} añadido a ${selectedList.name}'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Expanded(child: Text('No se pudo añadir a la lista. Es posible que ya exista.')),
                ],
              ),
              backgroundColor: Colors.orange.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final existingJournal = _getExistingJournal();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero header ────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildBlurredHeader(),
                ),
              ),

              // ── Body content ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status + ownership row
                      if (existingJournal != null)
                        _StatusRow(journal: existingJournal),

                      const SizedBox(height: 20),

                      // Genres
                      if (_data.genres.isNotEmpty)
                        _GenresSection(
                          genres: _data.genres,
                          accent: _typeColor,
                        ),

                      // Info rows
                      _InfoSection(data: _data, typeColor: _typeColor),

                      const SizedBox(height: 24),

                      // Action buttons
                      _buildActionButtons(existingJournal),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Loading overlay
          if (_isAdding)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x08000000),
                child: IgnorePointer(child: SizedBox()),
              ),
            ),
        ],
      ),
    );
  }

  // ── Blurred header ────────────────────────────────────────────────────────

  Widget _buildBlurredHeader() {
    final color = _typeColor;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Background: blurred cover image (or solid fallback)
        if (_data.coverUrl != null && _data.coverUrl!.isNotEmpty)
          CachedNetworkImage(
            imageUrl: _data.coverUrl!,
            fit: BoxFit.cover,
            // Don't show a placeholder here – we overlay everything anyway
            errorWidget: (_, _, _) => Container(color: color),
          )
        else
          Container(color: color),

        // 2. Blur filter
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(color: Colors.black.withValues(alpha: 0.48)),
        ),

        // 3. Gradient to help the body content read against the header
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.35),
                ],
              ),
            ),
          ),
        ),

        // 4. Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_typeIcon, size: 12, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        _typeLabel.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Sharp cover thumbnail
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 130,
                      height: 195,
                      child:
                          _data.coverUrl != null && _data.coverUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: _data.coverUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Container(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                              errorWidget: (_, _, _) =>
                                  _HeaderFallback(icon: _typeIcon),
                            )
                          : _HeaderFallback(icon: _typeIcon),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  _data.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 5),

                // Author
                Text(
                  _data.author,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Action buttons ────────────────────────────────────────────────────────

  Widget _buildActionButtons(dynamic existingJournal) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final subtleStyle = OutlinedButton.styleFrom(
      side: BorderSide(
        color: colorScheme.outlineVariant.withValues(alpha: 0.45),
      ),
    );

    final buttons = <Widget>[];

    if (existingJournal == null) {
      buttons.add(
        _PrimaryButton(
          icon: Icons.add_rounded,
          label: l10n.addToLibrary,
          isLoading: _isAdding,
          onTap: _showAddStatusDialog,
        ),
      );
    } else {
      final String? status = existingJournal.status;
      final bool isReading = status.isReading;
      final bool isFinished = status.isFinished;

      if (isReading) {
        buttons.addAll([
          _PrimaryButton(
            icon: Icons.menu_book_rounded,
            label: l10n.viewReadingProgress,
            onTap: () async {
              final route = switch (widget.type) {
                CatalogItemType.book => '/journal/book/progress',
                CatalogItemType.manga => '/journal/manga/progress',
                CatalogItemType.fanfic => '/journal/fanfic/progress',
              };
              await context.push(route, extra: existingJournal);
              _invalidateJournals(); // Refresca al cerrar el contador
            },
          ),
          const SizedBox(height: 10),
          _PrimaryButton(
            icon: Icons.timer_outlined,
            label: l10n.startReadingSession,
            onTap: () async {
              final route = switch (widget.type) {
                CatalogItemType.book => '/journal/book/session',
                CatalogItemType.manga => '/journal/manga/session',
                CatalogItemType.fanfic => '/journal/fanfic/session',
              };
              await context.push(route, extra: existingJournal);
              _invalidateJournals(); // Refresca al terminar la sesión
            },
            bgColor: AppColors.colorManga,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isAdding
                  ? null
                  : () => _showChangeStatusDialog(existingJournal),
              icon: const Icon(Icons.swap_horiz_rounded),
              label: Text(l10n.pauseOrAbandonReading),
              style: subtleStyle,
            ),
          ),
        ]);
      } else if (isFinished) {
        buttons.add(
          _PrimaryButton(
            icon: Icons.check_circle_rounded,
            label: l10n.viewInJournal,
            onTap: () => _openJournalEdit(existingJournal),
            bgColor: AppColors.statusFinished,
          ),
        );
      } else {
        buttons.add(
          _PrimaryButton(
            icon: Icons.book_rounded,
            label: '${l10n.statusLabel}: ${status.uiLabel}',
            onTap: () => _showChangeStatusDialog(existingJournal),
          ),
        );
      }

      if (!isFinished) {
        [
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openJournalEdit(existingJournal),
              icon: const Icon(Icons.book_outlined),
              label: Text(l10n.viewInJournal),
              style: subtleStyle,
            ),
          ),
        ];
      }
    }

    buttons.addAll([
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _openItemEdit(_currentItem),
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Editar datos'),
          style: subtleStyle,
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _showAddToListDialog,
          icon: const Icon(Icons.playlist_add_rounded),
          label: Text(l10n.addedToList),

          style: subtleStyle,
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: !_isAdding
              ? () {
                  final itemType = switch (widget.type) {
                    CatalogItemType.book => 'BOOK',
                    CatalogItemType.manga => 'MANGA',
                    CatalogItemType.fanfic => 'FANFIC',
                  };
                  final itemId = switch (widget.type) {
                    CatalogItemType.book =>
                      (_currentItem as BookResponseDTO).idBook,
                    CatalogItemType.manga =>
                      (_currentItem as MangaResponseDTO).idManga ?? 0,
                    CatalogItemType.fanfic =>
                      (_currentItem as FanfictionResponseDTO).idFanfic ?? 0,
                  };
                  if (itemId! > 0) {
                    context.push('/notes/$itemType/$itemId');
                  }
                }
              : null,
          icon: const Icon(Icons.note_alt_outlined),
          label: Text(l10n.notes),
          style: subtleStyle,
        ),
      ),
    ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: buttons,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderFallback extends StatelessWidget {
  final IconData icon;
  const _HeaderFallback({required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white.withValues(alpha: 0.08),
    child: Center(child: Icon(icon, size: 48, color: Colors.white38)),
  );
}

class _StatusRow extends StatelessWidget {
  final dynamic journal;
  const _StatusRow({required this.journal});

  Color _statusColor(String? s) => switch (s) {
    'READING' => AppColors.statusReading,
    'FINISHED' => AppColors.statusFinished,
    'PAUSED' => AppColors.statusPending,
    'DROPPED' => AppColors.statusAbandoned,
    _ => AppColors.statusPending,
  };

  @override
  Widget build(BuildContext context) {
    final String? status = journal.status;
    final String? ownership = journal.ownership;
    final color = _statusColor(status);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                status?.uiLabel ?? status ?? '',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        if (ownership != null &&
            ownership.isNotEmpty &&
            ownership.toUpperCase() != 'NONE') ...[
          const SizedBox(width: 8),
          OwnershipBadge(ownership: ownership),
        ],
      ],
    );
  }
}

class _GenresSection extends StatelessWidget {
  final List<String> genres;
  final Color accent;
  const _GenresSection({required this.genres, required this.accent});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Géneros',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.textSecondary(context),
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 7,
        runSpacing: 6,
        children: genres
            .map(
              (g) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent.withValues(alpha: 0.28)),
                ),
                child: Text(
                  g,
                  style: TextStyle(
                    fontSize: 12,
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 20),
    ],
  );
}

class _InfoSection extends StatelessWidget {
  final UnifiedCatalogData data;
  final Color typeColor;
  const _InfoSection({required this.data, required this.typeColor});

  @override
  Widget build(BuildContext context) {
    final rows = <_InfoRowData>[];

    if (data.totalChapters != null) {
      rows.add(
        _InfoRowData(
          Icons.format_list_numbered_rounded,
          'Capítulos',
          '${data.totalChapters}',
        ),
      );
    }
    if (data.pageCount != null && data.pageCount! > 0) {
      rows.add(
        _InfoRowData(
          Icons.auto_stories_rounded,
          'Páginas',
          '${data.pageCount}',
        ),
      );
    }
    if (data.publishYear != null) {
      rows.add(
        _InfoRowData(
          Icons.calendar_today_rounded,
          'Año',
          '${data.publishYear}',
        ),
      );
    }
    if (data.publisher != null && data.publisher!.isNotEmpty) {
      rows.add(
        _InfoRowData(Icons.business_rounded, 'Editorial', data.publisher!),
      );
    }
    if (data.malScore != null && data.malScore! > 0) {
      rows.add(
        _InfoRowData(Icons.star_rounded, 'Score MAL', '${data.malScore}'),
      );
    }
    if (data.demographic != null && data.demographic!.isNotEmpty) {
      rows.add(
        _InfoRowData(Icons.group_rounded, 'Demografía', data.demographic!),
      );
    }
    if (data.mainShip != null && data.mainShip!.isNotEmpty) {
      rows.add(
        _InfoRowData(Icons.favorite_rounded, 'Ship principal', data.mainShip!),
      );
    }
    if (data.theme != null && data.theme!.isNotEmpty) {
      rows.add(_InfoRowData(Icons.category_rounded, 'Tema', data.theme!));
    }
    if (data.publicationStatus != null && data.publicationStatus!.isNotEmpty) {
      rows.add(
        _InfoRowData(
          Icons.schedule_rounded,
          'Estado publicación',
          data.publicationStatus!,
        ),
      );
    }

    final desc = data.description;

    if (rows.isEmpty && (desc == null || desc.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (rows.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Column(
              children: rows.asMap().entries.map((e) {
                final isLast = e.key == rows.length - 1;
                final row = e.value;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            row.icon,
                            size: 16,
                            color: typeColor.withValues(alpha: 0.75),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            row.label,
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            row.value,
                            style: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: AppColors.border(context),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Synopsis
        if (desc != null && desc.isNotEmpty) ...[
          Text(
            'Sinopsis',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ],
    );
  }
}

class _InfoRowData {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRowData(this.icon, this.label, this.value);
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? bgColor;
  final bool isLoading;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.bgColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = bgColor ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onTap,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
