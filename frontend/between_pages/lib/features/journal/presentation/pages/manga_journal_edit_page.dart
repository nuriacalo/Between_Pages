import 'package:between_pages/models/journal/manga_journal_record_dto.dart';
import 'package:between_pages/models/journal/manga_journal_response_dto.dart';
import 'package:between_pages/providers/journal/manga_journal_provider.dart';
import 'package:between_pages/providers/user/user_provider.dart';
import 'package:between_pages/repositories/manga_journal_repository.dart';
import 'package:between_pages/repositories/journal_status_helper.dart';
import 'package:between_pages/widgets/journal/journal_edit_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MangaJournalEditPage extends ConsumerWidget {
  final MangaJournalResponseDTO journal;

  const MangaJournalEditPage({super.key, required this.journal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return JournalEditForm<MangaJournalResponseDTO, MangaJournalRecordDTO,
        MangaJournalRepository>(
      journal: journal,
      repositoryProvider: mangaJournalRepositoryProvider,
      recordDtoBuilder: (oldJournal, updatedValues) {
        final manga = oldJournal.manga;
        final userId = ref.read(userProfileProvider).value!.idUser;

        return MangaJournalRecordDTO(
          userId: userId,
          mangaId: manga?.idManga,
          malId: manga?.malId,
          status: updatedValues['status'] as String,
          rating: updatedValues['rating'] as int?,
          tearDrops: updatedValues['tearDrops'] as int?,
          spiceFlames: updatedValues['spiceFlames'] as int?,
          personalNotes: updatedValues['personalNotes'] as String?,
          startDate: oldJournal.startDate,
          endDate: updatedValues['endDate'] as String?,
          ownership: updatedValues['ownership'] as String?,
          rereading: oldJournal.rereading,
          currentChapter: updatedValues['currentChapter'] as int?,
          currentVolume: updatedValues['currentVolume'] as int?,
          readingFormat: updatedValues['readingFormat'] as String?,
          favoriteCharacter: updatedValues['favoriteCharacter'] as String?,
          favoriteArc: updatedValues['favoriteArc'] as String?,
        );
      },
      specificFieldsBuilder: (currentJournal, controllers) {
        // Initialize controllers if they don't exist
        controllers.putIfAbsent(
            'currentChapter',
            () => TextEditingController(
                text: currentJournal.currentChapter?.toString() ?? ''));
        controllers.putIfAbsent(
            'currentVolume',
            () => TextEditingController(
                text: currentJournal.currentVolume?.toString() ?? ''));
        controllers.putIfAbsent(
            'readingFormat',
            () => TextEditingController(
                text: currentJournal.readingFormat ?? ''));
        controllers.putIfAbsent(
            'favoriteCharacter',
            () => TextEditingController(
                text: currentJournal.favoriteCharacter ?? ''));
        controllers.putIfAbsent(
            'favoriteArc',
            () => TextEditingController(
                text: currentJournal.favoriteArc ?? ''));

        final List<String> formatOptions = ['Físico', 'Digital', 'Online'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progreso
            Text(
              'Progreso',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    context,
                    label: 'Capítulo actual',
                    controller: controllers['currentChapter']!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField(
                    context,
                    label: 'Volumen actual',
                    controller: controllers['currentVolume']!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Formato
            Text(
              'Formato de lectura',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 20),
            Wrap(
              spacing: 8,
              children: formatOptions.map((format) {
                final isSelected = controllers['readingFormat']?.text == format;
                return ChoiceChip(
                  label: Text(format),
                  selected: isSelected,
                  onSelected: (_) =>
                      controllers['readingFormat']?.text = format,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Personaje favorito
            Text(
              'Personaje favorito',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 20),
            TextField(
              controller: controllers['favoriteCharacter'],
              decoration: const InputDecoration(
                hintText: '¿Quién es tu personaje favorito?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Arco favorito
            Text(
              'Arco favorito',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 20),
            TextField(
              controller: controllers['favoriteArc'],
              decoration: const InputDecoration(
                hintText: '¿Cuál es tu arco/arco favorito?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
      onSave: (ref) {
        ref.invalidate(mangaJournalProvider);
        ref.invalidate(mangaJournalEntryProvider(journal.manga?.idManga ?? 0));
        // Si se marcó como terminado, abrir la pantalla inmersiva del Diario
        final dbStatus = JournalStatusHelper.mapStatusToDb(journal.status ?? 'TBR');
        if (dbStatus == 'FINISHED' && journal.status != 'FINISHED') {
          context.push('/journal/manga/diary', extra: journal);
        }
      },
    );
  }

  Widget _buildNumberField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    int max = 9999,
  }) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      controller: controller,
      onChanged: (v) {
        final num = int.tryParse(v);
        if (num != null && num >= 0 && num <= max) {
          controller.text = num.toString();
        } else if (v.isEmpty) {
          controller.text = '';
        }
      },
    );
  }
}
