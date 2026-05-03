import 'package:between_pages/models/catalog/book_response_dto.dart';
import 'package:between_pages/models/catalog/manga_response_dto.dart';
import 'package:between_pages/models/catalog/fanfiction_response_dto.dart';
import 'package:between_pages/models/journal/book_journal_response_dto.dart';
import 'package:between_pages/models/journal/fanfic_journal_response_dto.dart';
import 'package:between_pages/models/journal/manga_journal_response_dto.dart';
import 'package:between_pages/models/journal/book_journal_record_dto.dart';
import 'package:between_pages/models/journal/manga_journal_record_dto.dart';
import 'package:between_pages/models/journal/fanfic_journal_record_dto.dart';
import 'package:between_pages/providers/journal/book_journal_provider.dart';
import 'package:between_pages/providers/journal/manga_journal_provider.dart';
import 'package:between_pages/providers/journal/fanfic_journal_provider.dart';
import 'package:between_pages/providers/user/user_provider.dart';
import 'package:between_pages/repositories/book_journal_repository.dart';
import 'package:between_pages/repositories/manga_journal_repository.dart';
import 'package:between_pages/repositories/fanfic_journal_repository.dart';
import 'package:between_pages/screens/journal/book_journal_edit_page.dart';
import 'package:between_pages/screens/journal/manga_journal_edit_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum CatalogItemType { book, manga, fanfic }

class CatalogDetailPage extends ConsumerStatefulWidget {
  final dynamic
  item; // BookResponseDTO, MangaResponseDTO, or FanfictionResponseDTO
  final CatalogItemType type;

  const CatalogDetailPage({super.key, required this.item, required this.type});

  @override
  ConsumerState<CatalogDetailPage> createState() => _CatalogDetailPageState();
}

class _CatalogDetailPageState extends ConsumerState<CatalogDetailPage> {
  bool _isAdding = false;

  String _getTitle() {
    switch (widget.type) {
      case CatalogItemType.book:
        return (widget.item as BookResponseDTO).title;
      case CatalogItemType.manga:
        return (widget.item as MangaResponseDTO).title ?? 'Sin título';
      case CatalogItemType.fanfic:
        return (widget.item as FanfictionResponseDTO).title ?? 'Sin título';
    }
  }

  String? _getCoverUrl() {
    switch (widget.type) {
      case CatalogItemType.book:
        return (widget.item as BookResponseDTO).coverUrl;
      case CatalogItemType.manga:
        return (widget.item as MangaResponseDTO).coverUrl;
      case CatalogItemType.fanfic:
        return (widget.item as FanfictionResponseDTO).coverUrl;
    }
  }

  String _getAuthor() {
    switch (widget.type) {
      case CatalogItemType.book:
        return (widget.item as BookResponseDTO).author;
      case CatalogItemType.manga:
        return (widget.item as MangaResponseDTO).author ?? 'Autor desconocido';
      case CatalogItemType.fanfic:
        return (widget.item as FanfictionResponseDTO).author ??
            'Autor desconocido';
    }
  }

  String? _getDescription() {
    switch (widget.type) {
      case CatalogItemType.book:
        return (widget.item as BookResponseDTO).description;
      case CatalogItemType.manga:
        return (widget.item as MangaResponseDTO).description;
      case CatalogItemType.fanfic:
        return (widget.item as FanfictionResponseDTO).description;
    }
  }

  String? _getGenre() {
    switch (widget.type) {
      case CatalogItemType.book:
        return (widget.item as BookResponseDTO).genre;
      case CatalogItemType.manga:
        return (widget.item as MangaResponseDTO).genre;
      case CatalogItemType.fanfic:
        return (widget.item as FanfictionResponseDTO).genre;
    }
  }

  int? _getTotalChapters() {
    switch (widget.type) {
      case CatalogItemType.book:
        return null;
      case CatalogItemType.manga:
        return (widget.item as MangaResponseDTO).totalChapters;
      case CatalogItemType.fanfic:
        return (widget.item as FanfictionResponseDTO).totalChapters;
    }
  }

  String? _getPublicationStatus() {
    switch (widget.type) {
      case CatalogItemType.book:
        return null;
      case CatalogItemType.manga:
        return (widget.item as MangaResponseDTO).publicationStatus;
      case CatalogItemType.fanfic:
        return (widget.item as FanfictionResponseDTO).publicationStatus;
    }
  }

  dynamic _getExistingJournal() {
    switch (widget.type) {
      case CatalogItemType.book:
        final book = widget.item as BookResponseDTO;
        final asyncValue = ref.watch(bookJournalEntryProvider(book.idBook));
        return asyncValue.when(
          data: (data) => data,
          loading: () => null,
          error: (error, stackTrace) => null,
        );
      case CatalogItemType.manga:
        final manga = widget.item as MangaResponseDTO;
        final asyncValue = ref.watch(
          mangaJournalEntryProvider(manga.idManga ?? 0),
        );
        return asyncValue.when(
          data: (data) => data,
          loading: () => null,
          error: (error, stackTrace) => null,
        );
      case CatalogItemType.fanfic:
        final fanfic = widget.item as FanfictionResponseDTO;
        final asyncValue = ref.watch(
          fanficJournalEntryProvider(fanfic.idFanfic?.toString() ?? ''),
        );
        return asyncValue.when(
          data: (data) => data,
          loading: () => null,
          error: (error, stackTrace) => null,
        );
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
            title: book.title,
            author: book.author,
            description: book.description,
            coverUrl: book.coverUrl,
            genre: book.genre,
            bookType: book.bookType,
            publicationYear: book.publishYear,
            status: status,
            currentPage: 0,
          );
          await ref.read(bookJournalRepositoryProvider).saveOrUpdate(dto);
          break;

        case CatalogItemType.manga:
          final manga = widget.item as MangaResponseDTO;
          final dto = MangaJournalRecordDTO(
            userId: userId,
            mangaId: (manga.idManga ?? 0) > 0 ? manga.idManga : null,
            malId: manga.malId,
            source: manga.source,
            title: manga.title,
            mangaka: manga.author,
            demographic: manga.demographic,
            genre: manga.genre,
            description: manga.description,
            coverUrl: manga.coverUrl,
            totalChapters: manga.totalChapters,
            totalVolumes: manga.totalVolumes,
            publicationStatus: manga.publicationStatus,
            status: status,
            currentChapter: 0,
          );
          await ref.read(mangaJournalRepositoryProvider).saveOrUpdate(dto);
          break;

        case CatalogItemType.fanfic:
          final fanfic = widget.item as FanfictionResponseDTO;
          final dto = FanficJournalRecordDTO(
            userId: userId,
            fanfictionId: (fanfic.idFanfic ?? 0) > 0 ? fanfic.idFanfic : null,
            ao3Id: fanfic.ao3Id,
            title: fanfic.title,
            author: fanfic.author,
            sourceMaterial: fanfic.sourceMaterial,
            description: fanfic.description,
            coverUrl: fanfic.coverUrl,
            genre: fanfic.genre,
            theme: fanfic.theme,
            totalChapters: fanfic.totalChapters,
            publicationStatus: fanfic.publicationStatus,
            status: status,
            currentChapter: 0,
          );
          await ref.read(fanficJournalRepositoryProvider).saveOrUpdate(dto);
          break;
      }

      ref.invalidate(bookJournalProvider);
      ref.invalidate(mangaJournalProvider);
      ref.invalidate(fanficJournalProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'READING'
                ? 'Comenzaste a leer "${_getTitle()}"'
                : status == 'WISHLIST'
                ? 'Añadido a tu lista de deseos'
                : status == 'BOUGHT'
                ? 'Marcado como comprado'
                : '"${_getTitle()}" añadido a tu lista',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isAdding = false);
    }
  }

  void _openJournalEdit(dynamic journal) {
    switch (widget.type) {
      case CatalogItemType.book:
        context.push(
          '/journal/book/edit',
          extra: journal as BookJournalResponseDto,
        );
        break;
      case CatalogItemType.manga:
        context.push(
          '/journal/manga/edit',
          extra: journal as MangaJournalResponseDTO,
        );
        break;
      case CatalogItemType.fanfic:
        context.push(
          '/journal/fanfic/edit',
          extra: journal as FanficJournalResponseDTO,
        );
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
              label: const Text('Comenzar a leer'),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isAdding ? null : () => _addToJournal('PENDING'),
                  icon: const Icon(Icons.bookmark_add),
                  label: const Text('Pendiente'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isAdding ? null : () => _addToJournal('TBR'),
                  icon: const Icon(Icons.format_list_bulleted),
                  label: const Text('Por leer'),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: 'Más estados',
                onSelected: _isAdding ? null : (value) => _addToJournal(value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'WISHLIST',
                    child: Text('Añadir a Wishlist'),
                  ),
                  const PopupMenuItem(
                    value: 'BOUGHT',
                    child: Text('Marcar como Comprado'),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    }

    final status = existingJournal.status?.toString().toLowerCase() ?? '';
    final bool isReading =
        status.contains('leyendo') || status.contains('reading');
    final bool isFinished =
        status.contains('terminado') || status.contains('finished');

    return Column(
      children: [
        if (isReading) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                if (widget.type == CatalogItemType.book) {
                  // Te lleva a la pantalla de progreso e información
                  context.push(
                    '/journal/book/progress',
                    extra: existingJournal,
                  );
                } else if (widget.type == CatalogItemType.manga) {
                  context.push('/journal/manga/edit', extra: existingJournal);
                } else if (widget.type == CatalogItemType.fanfic) {
                  context.push('/journal/fanfic/edit', extra: existingJournal);
                }
              },
              icon: const Icon(Icons.menu_book),
              label: const Text('Ver progreso de lectura'),
            ),
          ),
          if (widget.type == CatalogItemType.book ||
              widget.type == CatalogItemType.manga ||
              widget.type == CatalogItemType.fanfic) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  String route;
                  if (widget.type == CatalogItemType.book) {
                    route = '/journal/book/session';
                  } else if (widget.type == CatalogItemType.manga) {
                    route = '/journal/manga/session';
                  } else {
                    route = '/journal/fanfic/session';
                  }
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
                label: const Text('Pausar o abandonar lectura'),
              ),
            ),
          ],
        ] else if (isFinished) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openJournalEdit(existingJournal),
              icon: const Icon(Icons.check_circle),
              label: const Text('Ver en journal'),
              style: FilledButton.styleFrom(backgroundColor: Colors.green),
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openJournalEdit(existingJournal),
              icon: const Icon(Icons.book),
              label: Text('Estado: ${existingJournal.status}'),
            ),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _openJournalEdit(existingJournal),
          icon: const Icon(Icons.edit),
          label: const Text('Editar journal'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final existingJournal = _getExistingJournal();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = const Color(0xFFA87C80);
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
                    child: _getCoverUrl() != null && _getCoverUrl()!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: _getCoverUrl()!,
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
                _getTitle(),
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
                _getAuthor(),
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
    final totalChapters = _getTotalChapters();
    final publicationStatus = _getPublicationStatus();
    final description = _getDescription();
    final genre = _getGenre();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (genre != null && genre.isNotEmpty) ...[
          _buildInfoRow(Icons.category, 'Género', genre),
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
