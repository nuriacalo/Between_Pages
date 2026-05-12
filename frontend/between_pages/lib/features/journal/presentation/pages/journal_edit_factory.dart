import 'package:between_pages/features/journal/domain/base_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/base_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/book_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/book_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/domain/manga_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/fanfic_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/fanfic_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/manga_journal_response_dto.dart';
import 'package:between_pages/features/profile/application/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JournalEditFactory {
  static BaseJournalRecordDTO Function(
    BaseJournalResponseDTO,
    Map<String, dynamic>,
    WidgetRef,
  ) getRecordDtoBuilder(JournalType type) {
    switch (type) {
      case JournalType.book:
        return (journal, updatedValues, ref) {
          final book = (journal as BookJournalResponseDto).book;
          final userId = ref.read(userProfileProvider).value!.idUser;
          return BookJournalRecordDTO(
            userId: userId,
            bookId: book.idBook,
            googleBooksId: book.googleBooksId,
            status: updatedValues['status'] as String,
            rating: updatedValues['rating'] as int?,
            tearDrops: updatedValues['tearDrops'] as int?,
            spiceFlames: updatedValues['spiceFlames'] as int?,
            personalNotes: updatedValues['personalNotes'] as String?,
            startDate: journal.startDate,
            endDate: updatedValues['endDate'] as String?,
            ownership: updatedValues['ownership'] as String?,
            rereading: journal.rereading,
            currentPage: int.tryParse(updatedValues['currentPage'] ?? '') ??
                journal.currentPage,
            favoriteQuotes: updatedValues['favoriteQuotes'] as String?,
            seriesName: updatedValues['seriesName'] as String?,
            seriesOrder: updatedValues['seriesOrder'] != null &&
                    (updatedValues['seriesOrder'] as String).isNotEmpty
                ? double.tryParse(updatedValues['seriesOrder'])
                : null,
            loanedTo: updatedValues['loanedTo'] as String?,
          );
        };

      case JournalType.manga:
        return (journal, updatedValues, ref) {
          final manga = (journal as MangaJournalResponseDTO).manga;
          final userId = ref.read(userProfileProvider).value!.idUser;
          final dbFormat = updatedValues['readingFormat'] == 'Físico'
              ? 'PHYSICAL'
              : (updatedValues['readingFormat'] == 'Digital' ? 'DIGITAL' : null);
          return MangaJournalRecordDTO(
            userId: userId,
            mangaId: manga?.idManga,
            malId: manga?.malId,
            status: updatedValues['status'] as String,
            rating: updatedValues['rating'] as int?,
            tearDrops: updatedValues['tearDrops'] as int?,
            spiceFlames: updatedValues['spiceFlames'] as int?,
            personalNotes: updatedValues['personalNotes'] as String?,
            startDate: journal.startDate,
            endDate: updatedValues['endDate'] as String?,
            ownership: updatedValues['ownership'] as String?,
            rereading: journal.rereading,
            currentChapter: updatedValues['currentChapter'] as int?,
            currentVolume: updatedValues['currentVolume'] as int?,
            readingFormat: dbFormat ?? updatedValues['readingFormat'] as String?,
            favoriteCharacter: updatedValues['favoriteCharacter'] as String?,
            favoriteArc: updatedValues['favoriteArc'] as String?,
          );
        };

      case JournalType.fanfic:
        return (journal, updatedValues, ref) {
          final fanfic = (journal as FanficJournalResponseDTO).fanfic;
          final userId = ref.read(userProfileProvider).value!.idUser;
          return FanficJournalRecordDTO(
            userId: userId,
            fanfictionId: fanfic.idFanfic,
            ao3Id: fanfic.ao3Id,
            status: updatedValues['status'] as String,
            rating: updatedValues['rating'] as int?,
            tearDrops: updatedValues['tearDrops'] as int?,
            spiceFlames: updatedValues['spiceFlames'] as int?,
            personalNotes: updatedValues['personalNotes'] as String?,
            startDate: journal.startDate,
            endDate: updatedValues['endDate'] as String?,
            rereading: journal.rereading,
            currentChapter:
                int.tryParse(updatedValues['currentChapter'] ?? '') ??
                    journal.currentChapter,
            mainShip: updatedValues['mainShip'] as String?,
            secondaryShips: updatedValues['secondaryShips'] as String?,
            angstLevel: updatedValues['angstLevel'] as String?,
            shipLoyalty: updatedValues['shipLoyalty'] as String?,
            canonType: updatedValues['canonType'] as String?,
          );
        };
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SPECIFIC FIELDS BUILDER
  // ─────────────────────────────────────────────────────────────────────────

  static Widget Function(
    dynamic,
    Map<String, TextEditingController>,
    BuildContext,
  ) getSpecificFieldsBuilder(JournalType type) {
    switch (type) {

      // ── LIBRO ────────────────────────────────────────────────────────────
      case JournalType.book:
        return (currentJournal, controllers, context) {
          controllers.putIfAbsent('currentPage',
              () => TextEditingController(text: currentJournal.currentPage?.toString() ?? ''));
          controllers.putIfAbsent('favoriteQuotes',
              () => TextEditingController(text: currentJournal.favoriteQuotes ?? ''));
          controllers.putIfAbsent('seriesName',
              () => TextEditingController(text: currentJournal.seriesName ?? ''));
          controllers.putIfAbsent('seriesOrder',
              () => TextEditingController(text: currentJournal.seriesOrder?.toString() ?? ''));
          controllers.putIfAbsent('loanedTo',
              () => TextEditingController(text: currentJournal.loanedTo ?? ''));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(label: 'Organización', icon: Icons.collections_bookmark_outlined),
              const SizedBox(height: 12),
              _StyledField(
                controller: controllers['seriesName']!,
                label: 'Nombre de la saga / serie',
                icon: Icons.collections_bookmark_outlined,
              ),
              const SizedBox(height: 12),
              _StyledField(
                controller: controllers['seriesOrder']!,
                label: 'Orden en la saga (ej: 1, 1.5, 2)',
                icon: Icons.format_list_numbered,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              _StyledField(
                controller: controllers['loanedTo']!,
                label: 'Prestado a...',
                hint: 'Nombre y fecha',
                icon: Icons.person_pin_outlined,
              ),
            ],
          );
        };

      // ── MANGA ────────────────────────────────────────────────────────────
      case JournalType.manga:
        return (currentJournal, controllers, context) {
          controllers.putIfAbsent('currentChapter',
              () => TextEditingController(text: currentJournal.currentChapter?.toString() ?? ''));
          controllers.putIfAbsent('currentVolume',
              () => TextEditingController(text: currentJournal.currentVolume?.toString() ?? ''));
          controllers.putIfAbsent('readingFormat',
              () => TextEditingController(text: currentJournal.readingFormat ?? ''));
          controllers.putIfAbsent('favoriteCharacter',
              () => TextEditingController(text: currentJournal.favoriteCharacter ?? ''));
          controllers.putIfAbsent('favoriteArc',
              () => TextEditingController(text: currentJournal.favoriteArc ?? ''));

          final formatDbToUi = {'PHYSICAL': 'Físico', 'DIGITAL': 'Digital'};
          final List<String> formatOptions = ['Físico', 'Digital'];
          controllers['readingFormat']!.text =
              formatDbToUi[currentJournal.readingFormat] ??
                  currentJournal.readingFormat ?? '';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(label: 'Progreso', icon: Icons.auto_stories_outlined),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StyledField(
                      controller: controllers['currentChapter']!,
                      label: 'Capítulo actual',
                      icon: Icons.bookmark_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StyledField(
                      controller: controllers['currentVolume']!,
                      label: 'Volumen actual',
                      icon: Icons.library_books_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SectionHeader(label: 'Formato de lectura', icon: Icons.devices_outlined),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: formatOptions.map((format) {
                  final isSelected = controllers['readingFormat']?.text == format;
                  return ChoiceChip(
                    label: Text(format),
                    selected: isSelected,
                    onSelected: (_) => controllers['readingFormat']?.text = format,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              _SectionHeader(label: 'Favoritos', icon: Icons.favorite_outline),
              const SizedBox(height: 12),
              _StyledField(
                controller: controllers['favoriteCharacter']!,
                label: 'Personaje favorito',
                hint: '¿Quién es tu personaje favorito?',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              _StyledField(
                controller: controllers['favoriteArc']!,
                label: 'Arco favorito',
                hint: '¿Cuál es tu arco favorito?',
                icon: Icons.timeline_outlined,
              ),
              const SizedBox(height: 24),
            ],
          );
        };

      // ── FANFIC ───────────────────────────────────────────────────────────
      case JournalType.fanfic:
        return (currentJournal, controllers, context) {
          final j = currentJournal as FanficJournalResponseDTO;
          controllers.putIfAbsent('currentChapter',
              () => TextEditingController(text: j.currentChapter?.toString() ?? ''));
          controllers.putIfAbsent('mainShip',
              () => TextEditingController(text: j.mainShip ?? ''));
          controllers.putIfAbsent('secondaryShips',
              () => TextEditingController(text: j.secondaryShips ?? ''));
          controllers.putIfAbsent('angstLevel',
              () => TextEditingController(text: j.angstLevel ?? ''));
          controllers.putIfAbsent('shipLoyalty',
              () => TextEditingController(text: j.shipLoyalty ?? ''));
          controllers.putIfAbsent('canonType',
              () => TextEditingController(text: j.canonType ?? ''));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(label: 'Progreso', icon: Icons.auto_stories_outlined),
              const SizedBox(height: 12),
              _StyledField(
                controller: controllers['currentChapter']!,
                label: 'Capítulo actual',
                icon: Icons.bookmark_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 24),
              _SectionHeader(label: 'Detalles', icon: Icons.favorite_outline),
              const SizedBox(height: 12),
              _StyledField(
                controller: controllers['mainShip']!,
                label: 'Ship principal',
                icon: Icons.favorite_outline,
              ),
              const SizedBox(height: 12),
              _StyledField(
                controller: controllers['secondaryShips']!,
                label: 'Ships secundarios',
                icon: Icons.people_outline,
              ),
              const SizedBox(height: 12),
              _StyledField(
                controller: controllers['canonType']!,
                label: 'Tipo de canon (ej: AU, Canon Divergence)',
                icon: Icons.alt_route_outlined,
              ),
              const SizedBox(height: 24),
            ],
          );
        };
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS PRIVADOS DEL ARCHIVO
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(color: color.withValues(alpha: 0.2)),
        ),
      ],
    );
  }
}

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

  const _StyledField({
    required this.controller,
    required this.label,
    this.hint,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F5FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}