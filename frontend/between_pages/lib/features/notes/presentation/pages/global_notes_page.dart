import 'package:between_pages/core/theme/app_colors.dart';
import 'package:between_pages/features/notes/application/providers/all_notes_provider.dart';
import 'package:between_pages/features/notes/domain/note_dto.dart';
import 'package:between_pages/l10n/app_localizations.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/journal/domain/responses/book_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/manga_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/fanfic_journal_response_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GlobalNotesPage extends ConsumerWidget {
  const GlobalNotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(allNotesProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        title: Text(
          l10n.notes,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
        ),
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error al cargar notas: $e')),
        data: (notes) {
          if (notes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.accent(context).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        Icons.edit_note_rounded,
                        size: 36,
                        color: AppColors.accent(context).withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Aún no tienes notas',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Las notas, citas y reflexiones que añadas a tus lecturas aparecerán aquí.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary(context),
                            height: 1.5,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return _GlobalNoteCard(note: note, index: index);
            },
          );
        },
      ),
    );
  }
}

class _GlobalNoteCard extends ConsumerWidget {
  final NoteDTO note;
  final int index;

  const _GlobalNoteCard({required this.note, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasQuote = note.quote != null && note.quote!.isNotEmpty;
    final hasNote = note.note != null && note.note!.isNotEmpty;
    final accent = _getAccent(note.itemType);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    JournalType? jType = switch (note.itemType.toUpperCase()) {
      'BOOK' => JournalType.book,
      'MANGA' => JournalType.manga,
      'FANFIC' => JournalType.fanfic,
      _ => null,
    };

    String? itemTitle;
    if (jType != null) {
      final entry = ref.watch(journalEntryProvider((jType, note.itemId)));
      if (entry != null) {
        if (entry is BookJournalResponseDto) {
          itemTitle = entry.book.title;
        } else if (entry is MangaJournalResponseDTO) itemTitle = entry.manga?.title;
        else if (entry is FanficJournalResponseDTO) itemTitle = entry.fanfic.title;
      }
    }

    // Ligera rotación aleatoria para dar sensación de "tablón de corcho"
    final angles = [-0.03, 0.02, -0.015, 0.035, 0.01, -0.025];
    final angle = angles[index % angles.length];

    // Color de papel (amarillento claro en modo claro, oscuro cálido en modo oscuro)
    final paperColor = isDark
        ? Color.lerp(AppColors.card(context), accent, 0.12)!
        : Color.lerp(const Color(0xFFFFFBEA), accent, 0.08)!;

    return Transform.rotate(
      angle: angle,
      child: GestureDetector(
        onTap: () => context.push('/notes/${note.itemType.toLowerCase()}/${note.itemId}'),
        child: Container(
          decoration: BoxDecoration(
            color: paperColor,
            borderRadius: BorderRadius.circular(4), // Bordes más cuadrados estilo post-it
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 6,
                offset: const Offset(2, 4),
              ),
            ],
            border: Border.all(
              color: accent.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            note.itemType.toUpperCase(),
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: accent,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (note.page != null) ...[
                          const Spacer(),
                          Text(
                            'p.${note.page}',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (itemTitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        itemTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context).withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ] else ...[
                      const SizedBox(height: 10),
                    ],
                    Expanded(
                      child: ClipRect(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasQuote)
                              Text(
                                '"${note.quote!}"',
                                maxLines: hasNote ? 3 : 7,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.textPrimary(context),
                                  height: 1.4,
                                ),
                              ),
                            if (hasQuote && hasNote) const SizedBox(height: 6),
                            if (hasNote)
                              Text(
                                note.note!,
                                maxLines: hasQuote ? 3 : 7,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary(context),
                                  height: 1.4,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Chincheta en el centro arriba
              Positioned(
                top: 4,
                left: 0,
                right: 0,
                child: Icon(
                  Icons.push_pin_rounded,
                  size: 18,
                  color: accent.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAccent(String type) {
    switch (type.toUpperCase()) {
      case 'BOOK':
        return AppColors.colorLibro;
      case 'MANGA':
        return AppColors.colorManga;
      case 'FANFIC':
        return AppColors.colorFanfic;
      default:
        return AppColors.lightAccent;
    }
  }
}