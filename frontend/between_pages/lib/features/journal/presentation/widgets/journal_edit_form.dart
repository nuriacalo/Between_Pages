import 'package:between_pages/core/repositories/journal_repository.dart';
import 'package:between_pages/features/journal/domain/base_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/base_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/utils/journal_status_helper.dart';
import 'package:between_pages/features/journal/presentation/widgets/emoji_rating_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class JournalEditForm<
    T extends BaseJournalResponseDTO,
    R extends BaseJournalRecordDTO> extends ConsumerStatefulWidget {
  final T journal;
  final JournalRepository repository;
  final R Function(T, Map<String, dynamic>) recordDtoBuilder;
  final Widget Function(T, Map<String, TextEditingController>)
      specificFieldsBuilder;
  final Function(WidgetRef) onSave;
  final Color? accentColor;

  const JournalEditForm({
    super.key,
    required this.journal,
    required this.repository,
    required this.recordDtoBuilder,
    required this.specificFieldsBuilder,
    required this.onSave,
    this.accentColor,
  });

  @override
  ConsumerState<JournalEditForm<T, R>> createState() =>
      _JournalEditFormState<T, R>();
}

class _JournalEditFormState<
    T extends BaseJournalResponseDTO,
    R extends BaseJournalRecordDTO> extends ConsumerState<JournalEditForm<T, R>> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late String _status;
  late int? _tearDrops;
  late int? _spiceFlames;
  late int? _rating;
  late String? _ownership;
  late final TextEditingController _personalNotesController;
  late final Map<String, TextEditingController> _specificControllers;

  static const _ownershipDbToUi = {
    'DIGITAL': 'Digital',
    'PHYSICAL': 'Físico',
    'NONE': 'Ninguno',
    'BORROWED': 'Prestado',
  };

  static const _ownershipUiToDb = {
    'Digital': 'DIGITAL',
    'Físico': 'PHYSICAL',
    'Ninguno': 'NONE',
    'Prestado': 'BORROWED',
  };

  @override
  void initState() {
    super.initState();
    final journal = widget.journal;
    _status = JournalStatusHelper.mapStatusToUi(journal.status);
    _tearDrops = journal.tearDrops;
    _spiceFlames = journal.spiceFlames;
    _rating = journal.rating;
    _ownership = _ownershipDbToUi[journal.ownership] ?? journal.ownership;
    _personalNotesController = TextEditingController(text: journal.personalNotes);
    _specificControllers = {};
  }

  @override
  void dispose() {
    _personalNotesController.dispose();
    for (var controller in _specificControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveJournal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final dbStatus = JournalStatusHelper.mapStatusToDb(_status);
      final isFinishing =
          dbStatus == 'FINISHED' && widget.journal.status != 'FINISHED';

      final specificValues = _specificControllers.map(
        (key, controller) => MapEntry(key, controller.text),
      );

      final dto = widget.recordDtoBuilder(
        widget.journal,
        {
          'status': dbStatus,
          'tearDrops': _tearDrops,
          'spiceFlames': _spiceFlames,
          'rating': _rating,
          'ownership': _ownership != null ? _ownershipUiToDb[_ownership] : null,
          'personalNotes': _personalNotesController.text,
          'endDate': isFinishing
              ? DateTime.now().toIso8601String()
              : widget.journal.endDate,
          ...specificValues,
        },
      );

      await widget.repository.saveRaw(dto.toJson());

      widget.onSave(ref);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal actualizado con éxito')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Journal'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
            )
          else
            IconButton(
          color: widget.accentColor,
              icon: const Icon(Icons.save_alt_outlined),
              onPressed: _saveJournal,
              tooltip: 'Guardar',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Common fields
            _buildStatusSelector(),
            _buildEmotionSelectors(),
            _buildRatingSelector(),
            _buildOwnershipSelector(),

            // Specific fields
            widget.specificFieldsBuilder(widget.journal, _specificControllers),

            // Notes
            _buildNotesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estado de lectura',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: JournalStatusHelper.statusOptions.map((status) {
            final isSelected = _status == status;
            return ChoiceChip(
              label: Text(status),
              selected: isSelected,
              selectedColor: widget.accentColor?.withValues(alpha: 0.2),
              side: isSelected && widget.accentColor != null
                  ? BorderSide(color: widget.accentColor!)
                  : null,
              onSelected: (_) => setState(() => _status = status),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

Widget _buildEmotionSelectors() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Emociones', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 16),
      EmojiRatingSelector(
        emoji: '💧',
        label: 'Lágrimas',
        value: _tearDrops,
        activeColor: const Color(0xFF5BA4C4),
        activeBg: const Color(0xFFE8F4F8),
        activeBorder: const Color(0xFF5BA4C4),
        onChanged: (v) => setState(() => _tearDrops = v),
      ),
      const SizedBox(height: 16),
      EmojiRatingSelector(
        emoji: '🔥',
        label: 'Spice',
        value: _spiceFlames,
        activeColor: const Color(0xFFE07A30),
        activeBg: const Color(0xFFFFF0E0),
        activeBorder: const Color(0xFFE07A30),
        onChanged: (v) => setState(() => _spiceFlames = v),
      ),
      const SizedBox(height: 24),
    ],
  );
}
 
  Widget _buildRatingSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Valoración (1-10)',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(10, (index) {
            final rating = index + 1;
            return ChoiceChip(
              label: Text('$rating'),
              selected: _rating == rating,
              selectedColor: widget.accentColor?.withValues(alpha: 0.2),
              side: _rating == rating && widget.accentColor != null
                  ? BorderSide(color: widget.accentColor!)
                  : null,
              onSelected: (_) => setState(() => _rating = rating),
            );
          }),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildOwnershipSelector() {
    final ownershipOptions = ['Digital', 'Físico', 'Ninguno', 'Prestado'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Propiedad', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ownershipOptions.map((ownership) {
            return ChoiceChip(
              label: Text(ownership),
              selected: _ownership == ownership,
              selectedColor: widget.accentColor?.withValues(alpha: 0.2),
              side: _ownership == ownership && widget.accentColor != null
                  ? BorderSide(color: widget.accentColor!)
                  : null,
              onSelected: (_) => setState(() => _ownership = ownership),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notas', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        TextFormField(
          controller: _personalNotesController,
          decoration: const InputDecoration(
            labelText: 'Notas personales',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 5,
          minLines: 3,
        ),
      ],
    );
  }
}
