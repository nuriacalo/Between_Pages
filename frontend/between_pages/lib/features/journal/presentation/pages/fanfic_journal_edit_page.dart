import 'package:between_pages/models/journal/fanfic_journal_record_dto.dart';
import 'package:between_pages/models/journal/fanfic_journal_response_dto.dart';
import 'package:between_pages/providers/journal/fanfic_journal_provider.dart';
import 'package:between_pages/providers/user/user_provider.dart';
import 'package:between_pages/repositories/fanfic_journal_repository.dart';
import 'package:between_pages/repositories/journal_status_helper.dart';
import 'package:between_pages/widgets/journal/journal_edit_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FanficJournalEditPage extends ConsumerWidget {
  final FanficJournalResponseDTO journal;

  const FanficJournalEditPage({super.key, required this.journal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return JournalEditForm<FanficJournalResponseDTO, FanficJournalRecordDTO,
        FanficJournalRepository>(
      journal: journal,
      repositoryProvider: fanficJournalRepositoryProvider,
      recordDtoBuilder: (oldJournal, updatedValues) {
        final fanfic = oldJournal.fanfic;
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
          startDate: oldJournal.startDate,
          endDate: updatedValues['endDate'] as String?,
          rereading: oldJournal.rereading,
          currentChapter: updatedValues['currentChapter'] as int?,
          mainShip: updatedValues['mainShip'] as String?,
          secondaryShips: updatedValues['secondaryShips'] as String?,
          angstLevel: updatedValues['angstLevel'] as String?,
          shipLoyalty: updatedValues['shipLoyalty'] as String?,
          canonType: updatedValues['canonType'] as String?,
        );
      },
      specificFieldsBuilder: (currentJournal, controllers) {
        // Initialize controllers if they don't exist
        controllers.putIfAbsent(
            'currentChapter',
            () => TextEditingController(
                text: currentJournal.currentChapter?.toString() ?? ''));
        controllers.putIfAbsent(
            'mainShip',
            () => TextEditingController(
                text: currentJournal.mainShip ?? ''));
        controllers.putIfAbsent(
            'secondaryShips',
            () => TextEditingController(
                text: currentJournal.secondaryShips ?? ''));
        controllers.putIfAbsent(
            'angstLevel',
            () => TextEditingController(
                text: currentJournal.angstLevel ?? ''));
        controllers.putIfAbsent(
            'shipLoyalty',
            () => TextEditingController(
                text: currentJournal.shipLoyalty ?? ''));
        controllers.putIfAbsent(
            'canonType',
            () => TextEditingController(
                text: currentJournal.canonType ?? ''));

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
            _buildNumberField(
              context,
              label: 'Capítulo actual',
              controller: controllers['currentChapter']!,
            ),
            const SizedBox(height: 16),

            // Fanfic Specific
            Text(
              'Detalles del Fanfic',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 20),
            TextField(
              controller: controllers['mainShip'],
              decoration: const InputDecoration(
                labelText: 'Ship Principal',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controllers['secondaryShips'],
              decoration: const InputDecoration(
                labelText: 'Ships Secundarios',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controllers['angstLevel'],
              decoration: const InputDecoration(
                labelText: 'Nivel de Angustia',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controllers['shipLoyalty'],
              decoration: const InputDecoration(
                labelText: 'Lealtad del Ship',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controllers['canonType'],
              decoration: const InputDecoration(
                labelText: 'Tipo de Canon',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
      onSave: (ref) {
        ref.invalidate(fanficJournalProvider);
        ref.invalidate(
            fanficJournalEntryProvider(journal.fanfic.idFanfic.toString()));
        // Si se marcó como terminado, abrir la pantalla inmersiva del Diario
        final dbStatus = JournalStatusHelper.mapStatusToDb(journal.status ?? 'TBR');
        if (dbStatus == 'FINISHED' && journal.status != 'FINISHED') {
          context.push('/journal/fanfic/diary', extra: journal);
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
