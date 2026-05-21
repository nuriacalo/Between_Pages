import 'package:between_pages/core/repositories/journal_repository.dart';
import 'package:between_pages/features/journal/domain/records/base_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/responses/base_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/fanfic_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/utils/journal_status_helper.dart';
import 'package:between_pages/features/journal/presentation/widgets/emoji_rating_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A generic, reusable form for editing any type of journal entry (Book, Manga, Fanfic).
/// 
/// This widget abstracts away the boilerplate of handling form state, emotional ratings 
/// (tear drops and spice flames), ownership status, and save operations.
/// 
/// [T] represents the specific response DTO type (e.g., BookJournalResponseDto).
/// [R] represents the specific record DTO type for saving (e.g., BookJournalRecordDTO).
class JournalEditForm<
    T extends BaseJournalResponseDTO,
    R extends BaseJournalRecordDTO> extends ConsumerStatefulWidget {
  
  /// The existing journal data to pre-fill the form.
  final T journal;
  
  /// The repository instance used to save the updated journal data.
  final JournalRepository repository;
  
  /// A builder function that constructs the specific record DTO [R] from the current 
  /// journal state and the updated values map.
  final R Function(T, Map<String, dynamic>) recordDtoBuilder;
  
  /// A builder function that provides UI for any media-specific fields (e.g., current page, current chapter).
  final Widget Function(T, Map<String, TextEditingController>)
      specificFieldsBuilder;
  
  /// Callback triggered immediately after a successful save operation.
  final Function(WidgetRef, String) onSave;
  
  /// Optional accent color to theme the form specific to the media type.
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
  late bool _isRereading;
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
    _isRereading = journal.rereading ?? false;
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

  /// Validates the form and triggers the save operation to the backend API.
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
          'rereading': _isRereading,
          'personalNotes': _personalNotesController.text,
          // Back usa LocalDate (YYYY-MM-DD). Evitamos mandar ISO8601 con hora/offset.
          'endDate': isFinishing
              ? DateTime.now().toLocal().toIso8601String().split('T').first
              : widget.journal.endDate,

          ...specificValues,
        },
      );

      await widget.repository.saveRaw(dto.toJson());

      widget.onSave(ref, dbStatus);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal actualizado con éxito')),
      );
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
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Detalles del Journal',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (_isSaving)
                const SizedBox(
                  width: 24, height: 24, 
                  child: CircularProgressIndicator(strokeWidth: 2.5)
                )
              else
                FilledButton.icon(
                  onPressed: _saveJournal,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Guardar'),
                  style: FilledButton.styleFrom(backgroundColor: widget.accentColor, foregroundColor: Colors.white),
                ),
            ],
          ),
          const SizedBox(height: 24),
            // Common fields
            _buildStatusSelector(),
            _buildRereadingToggle(),
            _buildEmotionSelectors(),
            _buildRatingSelector(),
            // En fanfic no usamos propiedad (siempre en inglés según requerimiento)
            // Propiedad no necesaria para fanfic; la ocultamos
            // Fanfic: no usamos propiedad
            // (Book/Manga sí soportan ownership)
            if (widget.journal is! FanficJournalResponseDTO) _buildOwnershipSelector(),

            // Specific fields
            widget.specificFieldsBuilder(widget.journal, _specificControllers),

            // Notes
            _buildNotesSection(),
          ],
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

  Widget _buildRereadingToggle() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: SwitchListTile(
            title: const Text('Relectura', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Aviso: Marcar como relectura actualizará las fechas de inicio y fin, borrando las originales.', style: TextStyle(fontSize: 12)),
            value: _isRereading,
            activeThumbColor: widget.accentColor ?? Theme.of(context).colorScheme.primary,
            onChanged: (bool value) {
              setState(() {
                _isRereading = value;
              });
            },
          ),
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
    final ownershipOptions = [
      (label: 'Digital', icon: Icons.phone_android_rounded),
      (label: 'Físico', icon: Icons.auto_stories_rounded),
      (label: 'Prestado', icon: Icons.people_alt_rounded),
      (label: 'Ninguno', icon: Icons.block_rounded),
    ];
    
    final activeColor = widget.accentColor ?? Theme.of(context).colorScheme.primary;
    final activeBg = activeColor.withValues(alpha: 0.15);
    final inactiveColor = Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Propiedad', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ownershipOptions.map((opt) {
            final isSelected = _ownership == opt.label;
            return GestureDetector(
              onTap: () => setState(() => _ownership = opt.label),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: isSelected ? activeBg : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? activeColor : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(opt.icon, color: isSelected ? activeColor : inactiveColor, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    opt.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? activeColor : inactiveColor,
                    ),
                  ),
                ],
              ),
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
