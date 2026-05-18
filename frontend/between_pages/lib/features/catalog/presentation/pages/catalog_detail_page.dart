import 'package:between_pages/features/catalog/application/repositories/fanfic_search_repository.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/catalog/application/repositories/book_search_repository.dart';
import 'package:between_pages/features/catalog/presentation/widgets/ownership_badge.dart';
import 'package:between_pages/features/journal/domain/book_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/book_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/fanfic_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/fanfic_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/domain/manga_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/manga_journal_response_dto.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/profile/application/providers/user_provider.dart';
import 'package:between_pages/features/journal/domain/utils/journal_status_extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:between_pages/l10n/app_localizations.dart'; // Import AppLocalizations

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

  UnifiedCatalogData({
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
  final dynamic item; // BookResponseDTO, MangaResponseDTO, or FanfictionResponseDTO
  final CatalogItemType type;

  const CatalogDetailPage({
    super.key,
    required this.item,
    required this.type,
  });

  @override
  ConsumerState<CatalogDetailPage> createState() => _CatalogDetailPageState();
}

class _CatalogDetailPageState extends ConsumerState<CatalogDetailPage> {
  bool _isAdding = false;
  late dynamic _currentItem;

  bool _isNotesEnabledForType() => widget.type == CatalogItemType.book;

  String _formatStatusLabel(String? status) {
    if (status == null || status.isEmpty) return '';
    return status.uiLabel;
  }

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
  }

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

  dynamic _getExistingJournal() {
    switch (widget.type) {
      case CatalogItemType.book:
        final book = _currentItem as BookResponseDTO;
        return ref.watch(journalEntryProvider((JournalType.book, book.idBook)));
      case CatalogItemType.manga:
        final manga = _currentItem as MangaResponseDTO;
        return ref.watch(journalEntryProvider((JournalType.manga, manga.idManga ?? 0)));
      case CatalogItemType.fanfic:
        final fanfic = _currentItem as FanfictionResponseDTO;
        return ref.watch(journalEntryProvider((JournalType.fanfic, fanfic.idFanfic ?? 0)));
    }
  }

  Future<void> _addToJournal(String status) async {
    if (_isAdding) return;
    if (!mounted) return;

    setState(() => _isAdding = true);

    try {
      final user = await ref.read(userProfileProvider.future);
      final userId = user.idUser;

      switch (widget.type) {
        case CatalogItemType.book:
          var book = _currentItem as BookResponseDTO;
          if (book.idBook == 0) {
            book = await ref.read(bookSearchRepositoryProvider).saveOrUpdateBook(book);
            setState(() {
              _currentItem = book;
            });
          }
          final dto = BookJournalRecordDTO(
            userId: userId,
            bookId: book.idBook,
            googleBooksId: book.googleBooksId,
            status: status,
            currentPage: 0,
          );
          await ref.read(bookJournalRepositoryProvider).saveRaw(dto.toJson());
          break;

        case CatalogItemType.manga:
          final manga = _currentItem as MangaResponseDTO;
          final int? mId = manga.idManga;
          final dto = MangaJournalRecordDTO(
            userId: userId,
            mangaId: (mId != null && mId > 0) ? mId : null,
            malId: manga.malId,
            status: status,
            currentChapter: 0,
          );
          await ref.read(mangaJournalRepositoryProvider).saveRaw(dto.toJson());
          break;

        case CatalogItemType.fanfic:
          var fanfic = _currentItem as FanfictionResponseDTO;
          if (fanfic.idFanfic == null || fanfic.idFanfic == 0) {
            fanfic = await ref.read(fanficSearchRepositoryProvider).saveOrUpdateFanfic(fanfic);
            setState(() {
              _currentItem = fanfic;
            });
          }
          final dto = FanficJournalRecordDTO(
            userId: userId,
            fanficId: fanfic.idFanfic!,
            ao3Id: fanfic.ao3Id,
            status: status,
            currentChapter: 0,
          );
          await ref.read(fanficJournalRepositoryProvider).saveRaw(dto.toJson());
          break;
      }

      ref.invalidate(journalProvider(JournalType.book));
      ref.invalidate(journalProvider(JournalType.manga));
      ref.invalidate(journalProvider(JournalType.fanfic));

      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      final msg = switch (status) {
        'READING' => l10n.startedReadingItem(_data.title),
        'WISHLIST' => l10n.addedToWishlistItem(_data.title),
        'TBR' => l10n.addedToTbrItem(_data.title),
        'FINISHED' => l10n.finishedReadingItem(_data.title),
        _ => l10n.addedToJournalItem(_data.title),
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isAdding = false);
    }
  }

  Future<void> _updateJournalStatus(dynamic existingJournal, String newStatus) async {
    if (_isAdding) return;
    if (!mounted) return;

    setState(() => _isAdding = true);

    try {
      final user = await ref.read(userProfileProvider.future);
      final userId = user.idUser;

      switch (widget.type) {
        case CatalogItemType.book:
          final journal = existingJournal as BookJournalResponseDto;
          final dto = BookJournalRecordDTO(
            id: journal.id, // Pass the existing journal's ID
            userId: userId,
            bookId: journal.book.idBook,
            googleBooksId: journal.book.googleBooksId,
            status: newStatus,
            currentPage: journal.currentPage,
          );
          await ref.read(bookJournalRepositoryProvider).updateRaw(dto.toJson()); // Pass only the JSON
          break;
        case CatalogItemType.manga:
          final journal = existingJournal as MangaJournalResponseDTO;
          final dto = MangaJournalRecordDTO(
            id: journal.id, // Pass the existing journal's ID
            userId: userId,
            mangaId: journal.manga?.idManga,
            malId: journal.manga?.malId,
            status: newStatus,
            currentChapter: journal.currentChapter,
          );
          await ref.read(mangaJournalRepositoryProvider).updateRaw(dto.toJson()); // Pass only the JSON
          break;
        case CatalogItemType.fanfic:
          final journal = existingJournal as FanficJournalResponseDTO;
          final dto = FanficJournalRecordDTO(
            id: journal.id, // Pass the existing journal's ID
            userId: userId,
            fanficId: journal.fanfic.idFanfic!,
            ao3Id: journal.fanfic.ao3Id,
            status: newStatus,
            currentChapter: journal.currentChapter,
          );
          await ref.read(fanficJournalRepositoryProvider).updateRaw(dto.toJson()); // Pass only the JSON
          break;
      }

      ref.invalidate(journalProvider(JournalType.book));
      ref.invalidate(journalProvider(JournalType.manga));
      ref.invalidate(journalProvider(JournalType.fanfic));

      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.statusUpdated(_data.title, newStatus.uiLabel))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isAdding = false);
    }
  }

  void _openJournalEdit(dynamic journal) {
    switch (widget.type) {
      case CatalogItemType.book:
        context.push('/journal/book/edit', extra: journal as BookJournalResponseDto);
        break;
      case CatalogItemType.manga:
        context.push('/journal/manga/edit', extra: journal as MangaJournalResponseDTO);
        break;
      case CatalogItemType.fanfic:
        context.push('/journal/fanfic/edit', extra: journal as FanficJournalResponseDTO);
        break;
    }
  }

  Future<void> _showAddStatusDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final selectedStatus = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addToJournal),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.statusReading),
              onTap: () => Navigator.pop(context, 'READING'),
            ),
            ListTile(
              title: Text(l10n.statusTBR),
              onTap: () => Navigator.pop(context, 'TBR'),
            ),
            ListTile(
              title: Text(l10n.statusFinished),
              onTap: () => Navigator.pop(context, 'FINISHED'),
            ),
            ListTile(
              title: Text(l10n.statusWishlist),
              onTap: () => Navigator.pop(context, 'WISHLIST'),
            ),
          ],
        ),
      ),
    );
    if (selectedStatus != null) {
      _addToJournal(selectedStatus);
    }
  }

  Future<void> _showChangeStatusDialog(dynamic existingJournal) async {
    final l10n = AppLocalizations.of(context)!;
    final selectedStatus = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.changeStatus),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.statusReading),
              onTap: () => Navigator.pop(context, 'READING'),
            ),
            ListTile(
              title: Text(l10n.statusTBR),
              onTap: () => Navigator.pop(context, 'TBR'),
            ),
            ListTile(
              title: Text(l10n.statusFinished),
              onTap: () => Navigator.pop(context, 'FINISHED'),
            ),
            ListTile(
              title: Text(l10n.statusPaused),
              onTap: () => Navigator.pop(context, 'PAUSED'),
            ),
            ListTile(
              title: Text(l10n.statusDropped),
              onTap: () => Navigator.pop(context, 'DROPPED'),
            ),
            ListTile(
              title: Text(l10n.statusWishlist),
              onTap: () => Navigator.pop(context, 'WISHLIST'),
            ),
          ],
        ),
      ),
    );
    if (selectedStatus != null) {
      _updateJournalStatus(existingJournal, selectedStatus);
    }
  }

  Widget _buildActionButtons(dynamic existingJournal) {
    final l10n = AppLocalizations.of(context)!;

    if (existingJournal == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isAdding ? null : _showAddStatusDialog,
              icon: const Icon(Icons.add),
              label: Text(l10n.addToJournal),
            ),
          ),
          if (_isAdding)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text(l10n.saving),
                ],
              ),
            ),
        ],
      );
    }

    final String? status = existingJournal.status;
    final bool isReading = status.isReading;
    final bool isFinished = status.isFinished;

    return Column(
      children: [
        if (isReading) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                if (widget.type == CatalogItemType.book) {
                  context.push('/journal/book/progress', extra: existingJournal);
                } else if (widget.type == CatalogItemType.manga) {
                  context.push('/journal/manga/edit', extra: existingJournal);
                } else {
                  context.push('/journal/fanfic/edit', extra: existingJournal);
                }
              },
              icon: const Icon(Icons.menu_book),
              label: Text(l10n.viewReadingProgress),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                final route = switch (widget.type) {
                  CatalogItemType.book => '/journal/book/session',
                  CatalogItemType.manga => '/journal/manga/session',
                  CatalogItemType.fanfic => '/journal/fanfic/session',
                };
                context.push(route, extra: existingJournal);
              },
              icon: const Icon(Icons.timer_outlined),
              label: Text(l10n.startReadingSession),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isAdding ? null : () => _showChangeStatusDialog(existingJournal),
              icon: const Icon(Icons.pause),
              label: Text(l10n.pauseOrAbandonReading),
            ),
          ),
        ] else if (isFinished) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openJournalEdit(existingJournal),
              icon: const Icon(Icons.check_circle),
              label: Text(l10n.viewInJournal),
              style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondaryContainer),
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isAdding ? null : () => _showChangeStatusDialog(existingJournal),
              icon: const Icon(Icons.book),
              label: Text('${l10n.statusLabel}: ${status.uiLabel}'),
            ),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _openJournalEdit(existingJournal),
          icon: const Icon(Icons.edit),
          label: Text(l10n.editJournal),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isNotesEnabledForType() && !_isAdding
              ? () {
                  final journal = existingJournal as BookJournalResponseDto;
                  if (journal.book.idBook > 0) {
                    context.push('/notes', extra: journal.book.idBook);
                  }
                }
              : null,
          icon: const Icon(Icons.note_alt_outlined),
          label: Text(l10n.notes),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final existingJournal = _getExistingJournal();
    final accent = Theme.of(context).colorScheme.secondary;
    final bgColor = Theme.of(context).colorScheme.surfaceContainerLow;

    final statusLabel = existingJournal == null ? null : _formatStatusLabel(existingJournal.status);
    final statusChipColor = Theme.of(context).colorScheme.secondaryContainer;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                backgroundColor: accent,
                foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                flexibleSpace: FlexibleSpaceBar(background: _buildHeader(accent)),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (statusLabel != null && statusLabel.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusChipColor,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (existingJournal?.ownership != null && existingJournal!.ownership!.isNotEmpty && existingJournal!.ownership != 'NONE') ...[
                                const SizedBox(width: 8),
                                OwnershipBadge(ownership: existingJournal.ownership!),
                              ],
                            ],
                          ),
                        ),
                      _buildInfoSection(accent),
                      const SizedBox(height: 24),
                      _buildActionButtons(existingJournal),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isAdding)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withOpacity(0.05),
                child: const IgnorePointer(child: SizedBox()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color accent) {
    return Container(
      color: accent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 140,
                    height: 210,
                    child: _data.coverUrl != null && _data.coverUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: _data.coverUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.white.withOpacity(0.1),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.white.withOpacity(0.1),
                              child: const Icon(
                                Icons.book,
                                color: Colors.white54,
                                size: 50,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.white.withOpacity(0.1),
                            child: const Icon(
                              Icons.book,
                              color: Colors.white54,
                              size: 50,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _data.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _data.author,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(Color accent) {
    final l10n = AppLocalizations.of(context)!;
    final totalChapters = _data.totalChapters;
    final publicationStatus = _data.publicationStatus;
    final description = _data.description;
    final genres = _data.genres;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (genres.isNotEmpty) ...[
          Text(
            l10n.genres,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: accent,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: genres.map((genre) => Chip(label: Text(genre))).toList(),
          ),
          const SizedBox(height: 12),
        ],
        if (totalChapters != null) ...[
          _buildInfoRow(
            Icons.format_list_numbered,
            l10n.chapters,
            '$totalChapters',
          ),
          const SizedBox(height: 12),
        ],
        if (_data.pageCount != null && _data.pageCount! > 0) ...[
          _buildInfoRow(Icons.auto_stories, l10n.pages, '${_data.pageCount}'),
          const SizedBox(height: 12),
        ],
        if (_data.publishYear != null) ...[
          _buildInfoRow(Icons.calendar_today_outlined, l10n.publishYear, '${_data.publishYear}'),
          const SizedBox(height: 12),
        ],
        if (_data.publisher != null && _data.publisher!.isNotEmpty) ...[
          _buildInfoRow(Icons.business_outlined, l10n.publisher, _data.publisher!),
          const SizedBox(height: 12),
        ],
        if (_data.malScore != null && _data.malScore! > 0) ...[
          _buildInfoRow(Icons.star_outline, l10n.malScore, '${_data.malScore}'),
          const SizedBox(height: 12),
        ],
        if (_data.demographic != null && _data.demographic!.isNotEmpty) ...[
          _buildInfoRow(Icons.group_outlined, l10n.demographic, _data.demographic!),
          const SizedBox(height: 12),
        ],
        if (_data.mainShip != null && _data.mainShip!.isNotEmpty) ...[
          _buildInfoRow(Icons.favorite_border, l10n.mainShip, _data.mainShip!),
          const SizedBox(height: 12),
        ],
        if (_data.theme != null && _data.theme!.isNotEmpty) ...[
          _buildInfoRow(Icons.category_outlined, l10n.theme, _data.theme!),
          const SizedBox(height: 12),
        ],
        if (publicationStatus != null && publicationStatus.isNotEmpty) ...[
          _buildInfoRow(Icons.schedule, l10n.statusLabel, publicationStatus),
          const SizedBox(height: 12),
        ],
        if (description != null && description.isNotEmpty) ...[
          const Divider(height: 24),
          Text(
            l10n.synopsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey[700],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(value, style: TextStyle(color: Colors.grey[800])),
        ),
      ],
    );
  }
}