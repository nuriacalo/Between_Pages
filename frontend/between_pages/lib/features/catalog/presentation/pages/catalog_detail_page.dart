import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/journal/domain/book_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/book_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/fanfic_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/fanfic_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/manga_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/manga_journal_response_dto.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/journal/domain/journal_type.dart';
import 'package:between_pages/features/profile/application/providers/user_provider.dart';
import 'package:between_pages/features/journal/domain/utils/journal_status_extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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

  UnifiedCatalogData get _data {
    switch (widget.type) {
      case CatalogItemType.book:
        final b = widget.item as BookResponseDTO;
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
        final m = widget.item as MangaResponseDTO;
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
        final f = widget.item as FanfictionResponseDTO;
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
        final book = widget.item as BookResponseDTO;
        return ref.watch(journalEntryProvider((JournalType.book, book.idBook)));
      case CatalogItemType.manga:
        final manga = widget.item as MangaResponseDTO;
        return ref.watch(journalEntryProvider((JournalType.manga, manga.idManga ?? 0)));
      case CatalogItemType.fanfic:
        final fanfic = widget.item as FanfictionResponseDTO;
        return ref.watch(journalEntryProvider((JournalType.fanfic, fanfic.idFanfic ?? 0)));
    }
  }

  Future<void> _addToJournal(String status) async {
    if (_isAdding) return;
    setState(() => _isAdding = true);

    try {
      final user = await ref.read(userProfileProvider.future);
      final userId = user.idUser;

      switch (widget.type) {
        case CatalogItemType.book:
          final book = widget.item as BookResponseDTO;
          final dto = BookJournalRecordDTO(
            userId: userId,
            bookId: book.idBook > 0 ? book.idBook : null,
            googleBooksId: book.googleBooksId,
            status: status,
            currentPage: 0,
          );
          await ref.read(bookJournalRepositoryProvider).saveRaw(dto.toJson());
          break;

        case CatalogItemType.manga:
          final manga = widget.item as MangaResponseDTO;
          final int? mId = manga.idManga; // Asignación segura para evaluar nulidad
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
          final fanfic = widget.item as FanfictionResponseDTO;
          final int? fId = fanfic.idFanfic;
          final dto = FanficJournalRecordDTO(
            userId: userId,
            fanfictionId: (fId != null && fId > 0) ? fId : null,
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

      final msg = switch (status) {
        'READING' => 'Empezaste a leer "${_data.title}"',
        'WISHLIST' => 'Añadido a la wishlist',
        'TBR' => '"${_data.title}" añadido a la lista',
        _ => '"${_data.title}" añadido a la lista',
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

  Widget _buildActionButtons(dynamic existingJournal) {
    if (existingJournal == null) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isAdding ? null : () => _addToJournal('READING'),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Empezar a leer'),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isAdding ? null : () => _addToJournal('TBR'),
                  icon: const Icon(Icons.bookmark_add),
                  label: const Text('Quiero leer'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isAdding ? null : () => _addToJournal('READING'),
                  icon: const Icon(Icons.timer_outlined),
                  label: const Text('Leyendo'),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: 'Más estados',
                onSelected: _isAdding ? null : _addToJournal,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'WISHLIST',
                    child: const Text('Añadir a wishlist'),
                  ),
                ],
              ),
            ],
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
              label: const Text('Ver progreso de lectura'),
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
              label: const Text('Iniciar sesión de lectura'),
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
              onPressed: () => _openJournalEdit(existingJournal),
              icon: const Icon(Icons.pause),
              label: const Text('Pausar o abandonar'),
            ),
          ),
        ] else if (isFinished) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openJournalEdit(existingJournal),
              icon: const Icon(Icons.check_circle),
              label: const Text('Ver en el Journal'),
              style: FilledButton.styleFrom(backgroundColor: Colors.green),
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openJournalEdit(existingJournal),
              icon: const Icon(Icons.book),
              label: Text('Estado: ${status.uiLabel}'),
            ),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _openJournalEdit(existingJournal),
          icon: const Icon(Icons.edit),
          label: const Text('Editar Journal'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final existingJournal = _getExistingJournal();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accent = Color(0xFFA87C80);
    final bgColor = isDark ? const Color(0xFF2C2025) : const Color(0xFFF5E6E0);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: accent,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(background: _buildHeader(accent)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(accent),
                  const SizedBox(height: 24),
                  _buildActionButtons(existingJournal),
                ],
              ),
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
                      color: Colors.black.withValues(alpha: 0.3),
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
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.white.withValues(alpha: 0.1),
                              child: const Icon(
                                Icons.book,
                                color: Colors.white54,
                                size: 50,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.white.withValues(alpha: 0.1),
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
                  color: Colors.white.withValues(alpha: 0.9),
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
    final totalChapters = _data.totalChapters;
    final publicationStatus = _data.publicationStatus;
    final description = _data.description;
    final genres = _data.genres;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (genres.isNotEmpty) ...[
          Text(
            'Géneros',
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
            'Capítulos',
            '$totalChapters',
          ),
          const SizedBox(height: 12),
        ],
        if (_data.pageCount != null && _data.pageCount! > 0) ...[
          _buildInfoRow(Icons.auto_stories, 'Páginas', '${_data.pageCount}'),
          const SizedBox(height: 12),
        ],
        if (_data.publishYear != null) ...[
          _buildInfoRow(Icons.calendar_today_outlined, 'Año de publicación', '${_data.publishYear}'),
          const SizedBox(height: 12),
        ],
        if (_data.publisher != null && _data.publisher!.isNotEmpty) ...[
          _buildInfoRow(Icons.business_outlined, 'Editorial', _data.publisher!),
          const SizedBox(height: 12),
        ],
        if (_data.malScore != null && _data.malScore! > 0) ...[
          _buildInfoRow(Icons.star_outline, 'Puntuación MAL', '${_data.malScore}'),
          const SizedBox(height: 12),
        ],
        if (_data.demographic != null && _data.demographic!.isNotEmpty) ...[
          _buildInfoRow(Icons.group_outlined, 'Demografía', _data.demographic!),
          const SizedBox(height: 12),
        ],
        if (_data.mainShip != null && _data.mainShip!.isNotEmpty) ...[
          _buildInfoRow(Icons.favorite_border, 'Ship principal', _data.mainShip!),
          const SizedBox(height: 12),
        ],
        if (_data.theme != null && _data.theme!.isNotEmpty) ...[
          _buildInfoRow(Icons.category_outlined, 'Tema', _data.theme!),
          const SizedBox(height: 12),
        ],
        if (publicationStatus != null && publicationStatus.isNotEmpty) ...[
          _buildInfoRow(Icons.schedule, 'Estado', publicationStatus),
          const SizedBox(height: 12),
        ],
        if (description != null && description.isNotEmpty) ...[
          const Divider(height: 24),
          Text(
            'Sinopsis',
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
