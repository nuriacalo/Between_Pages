import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/domain/responses/base_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/book_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/fanfic_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/manga_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/utils/journal_status_helper.dart';
import 'package:between_pages/features/journal/presentation/pages/journal_edit_factory.dart';
import 'package:between_pages/features/journal/presentation/widgets/journal_edit_form.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class JournalItemEditPage extends ConsumerWidget {
  final BaseJournalResponseDTO journal;
  final JournalType type;
  final bool isStandalone;

  const JournalItemEditPage({super.key, required this.journal, required this.type, this.isStandalone = true});

  // ── Datos extraídos del journal según tipo ──────────────────────────────────

  String get _title {
    if (journal is BookJournalResponseDto) return (journal as BookJournalResponseDto).book.title;
    if (journal is MangaJournalResponseDTO) return (journal as MangaJournalResponseDTO).manga?.title ?? 'Sin título';
    if (journal is FanficJournalResponseDTO) return (journal as FanficJournalResponseDTO).fanfic.title ?? 'Sin título';
    return 'Sin título';
  }

  String? get _subtitle {
    if (journal is BookJournalResponseDto) return (journal as BookJournalResponseDto).book.author;
    if (journal is FanficJournalResponseDTO) return (journal as FanficJournalResponseDTO).fanfic.author;
    return null;
  }

  String? get _coverUrl {
    if (journal is BookJournalResponseDto) return (journal as BookJournalResponseDto).book.coverUrl;
    if (journal is MangaJournalResponseDTO) return (journal as MangaJournalResponseDTO).manga?.coverUrl;
    if (journal is FanficJournalResponseDTO) return (journal as FanficJournalResponseDTO).fanfic.coverUrl;
    return null;
  }

  // ── Configuración visual por tipo ──────────────────────────────────────────

  ({Color accent, IconData icon, String label}) get _typeConfig => switch (type) {
    JournalType.book  => (accent: const Color(0xFFA87C80), icon: Icons.menu_book_rounded,   label: 'Libro'),
    JournalType.manga => (accent: const Color(0xFF5B7FA6), icon: Icons.auto_stories_rounded, label: 'Manga'),
    JournalType.fanfic=> (accent: const Color(0xFF8B6BAE), icon: Icons.favorite_rounded,     label: 'Fanfic'),
  };

  Color get _statusColor => switch (journal.status.trim().toUpperCase()) {
    'READING'  => const Color(0xFF4CAF50),
    'FINISHED' => const Color(0xFF2196F3),
    'PAUSED'   => const Color(0xFFFF9800),
    'TBR'      => const Color(0xFF00BCD4),
    'WISHLIST' => const Color(0xFF9C27B0),
    'DROPPED'  => const Color(0xFFF44336),
    _          => Colors.grey,
  };

  String get _statusLabel => switch (journal.status.trim().toUpperCase()) {
    'READING'  => 'Leyendo',
    'FINISHED' => 'Terminado',
    'PAUSED'   => 'Pausado',
    'TBR'      => 'Por leer',
    'WISHLIST' => 'Wishlist',
    'DROPPED'  => 'Abandonado',
    _          => journal.status,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = _typeConfig;
    final recordDtoBuilder    = JournalEditFactory.getRecordDtoBuilder(type);
    final specificFieldsBuilder = JournalEditFactory.getSpecificFieldsBuilder(type);
    final repository          = ref.watch(_getRepositoryProvider(type));

    final form = JournalEditForm(
          journal: journal,
          repository: repository,
          recordDtoBuilder: (oldJournal, updatedValues) =>
              recordDtoBuilder(oldJournal, updatedValues, ref),
          specificFieldsBuilder: (currentJournal, controllers) =>
              specificFieldsBuilder(currentJournal, controllers, context),
          accentColor: config.accent,      // <-- pasa el acento al form
          onSave: (ref, newStatus) {
            _invalidateProviders(ref, type, journal);
            final oldDbStatus = JournalStatusHelper.mapStatusToDb(journal.status);
            if (newStatus == 'FINISHED' && oldDbStatus != 'FINISHED') {
              context.push('/journal/${type.name}/diary', extra: journal);
            } else if (isStandalone) {
              context.pop();
            }
          },
    );

    if (!isStandalone) {
      return form;
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerScrolled) => [
          _HeroAppBar(
            title: _title,
            subtitle: _subtitle,
            coverUrl: _coverUrl,
            accent: config.accent,
            typeIcon: config.icon,
            typeLabel: config.label,
            statusLabel: _statusLabel,
            statusColor: _statusColor,
          ),
        ],
        body: form,
      ),
    );
  }

  ProviderBase _getRepositoryProvider(JournalType type) => switch (type) {
    JournalType.book   => bookJournalRepositoryProvider,
    JournalType.manga  => mangaJournalRepositoryProvider,
    JournalType.fanfic => fanficJournalRepositoryProvider,
  };

  void _invalidateProviders(WidgetRef ref, JournalType type, dynamic journal) {
    ref.invalidate(journalProvider(type));
    int? itemId;
    if (journal is BookJournalResponseDto)  itemId = journal.book.idBook;
    if (journal is MangaJournalResponseDTO) itemId = journal.manga?.idManga;
    if (journal is FanficJournalResponseDTO) itemId = journal.fanfic.idFanfic;
    if (itemId != null) ref.invalidate(journalEntryProvider((type, itemId)));
  }
}

// ── Hero SliverAppBar ─────────────────────────────────────────────────────────

class _HeroAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? coverUrl;
  final Color accent;
  final IconData typeIcon;
  final String typeLabel;
  final String statusLabel;
  final Color statusColor;

  const _HeroAppBar({
    required this.title,
    this.subtitle,
    this.coverUrl,
    required this.accent,
    required this.typeIcon,
    required this.typeLabel,
    required this.statusLabel,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: accent,
      foregroundColor: Colors.white,
      elevation: 0,
      // Título compacto cuando está colapsado
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: ColoredBox(
          color: accent,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ── Portada ──────────────────────────────────────────────
                  _Cover(coverUrl: coverUrl, accent: accent, typeIcon: typeIcon),
                  const SizedBox(width: 16),

                  // ── Info ─────────────────────────────────────────────────
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tipo (Libro / Manga / Fanfic)
                        Row(
                          children: [
                            Icon(typeIcon, size: 12, color: Colors.white60),
                            const SizedBox(width: 4),
                            Text(
                              typeLabel.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white60,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Título
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),

                        // Subtítulo (autor)
                        if (subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],

                        const SizedBox(height: 10),

                        // Chip de estado
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24, width: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                statusLabel,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
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
          ),
        ),
      ),
    );
  }
}

// ── Portada ───────────────────────────────────────────────────────────────────

class _Cover extends StatelessWidget {
  final String? coverUrl;
  final Color accent;
  final IconData typeIcon;

  const _Cover({this.coverUrl, required this.accent, required this.typeIcon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 118,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: coverUrl != null && coverUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: coverUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => _PlaceholderCover(accent: accent, icon: typeIcon),
                errorWidget: (_, _, _) => _PlaceholderCover(accent: accent, icon: typeIcon),
              )
            : _PlaceholderCover(accent: accent, icon: typeIcon),
      ),
    );
  }
}

class _PlaceholderCover extends StatelessWidget {
  final Color accent;
  final IconData icon;

  const _PlaceholderCover({required this.accent, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: accent.withValues(alpha: 0.6),
      child: Center(
        child: Icon(icon, color: Colors.white54, size: 32),
      ),
    );
  }
}