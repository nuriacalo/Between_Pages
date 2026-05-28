import 'package:between_pages/core/theme/app_colors.dart';
import 'package:between_pages/features/catalog/application/repositories/catalog_repository.dart';
import 'package:between_pages/features/catalog/application/providers/all_fanfics_provider.dart';
import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/catalog/presentation/widgets/edit_form_widgets.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/journal/domain/records/fanfic_journal_record_dto.dart';
import 'package:between_pages/features/profile/application/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FanficEditPage extends ConsumerStatefulWidget {
  final FanfictionResponseDTO? fanfic;
  const FanficEditPage({super.key, this.fanfic});

  @override
  ConsumerState<FanficEditPage> createState() => _FanficEditPageState();
}

class _FanficEditPageState extends ConsumerState<FanficEditPage> {
  static const _accent = AppColors.colorFanfic; // 0xFFD4A0A4

  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _sourceMaterialController;
  late final TextEditingController _totalChaptersController;
  late final TextEditingController _coverUrlController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagsController;
  late final TextEditingController _mainShipController;
  late final TextEditingController _themeController;
  String _publicationStatus = 'ONGOING';

  @override
  void initState() {
    super.initState();
    final f = widget.fanfic;
    _titleController          = TextEditingController(text: f?.title ?? '');
    _authorController         = TextEditingController(text: f?.author ?? '');
    _sourceMaterialController = TextEditingController(text: f?.sourceMaterial ?? '');
    _totalChaptersController  = TextEditingController(text: f?.totalChapters?.toString() ?? '');
    _coverUrlController       = TextEditingController(text: f?.coverUrl ?? '');
    _descriptionController    = TextEditingController(text: f?.description ?? '');
    _tagsController           = TextEditingController(text: (f?.tags ?? []).join(', '));
    _mainShipController       = TextEditingController(text: f?.mainShip ?? '');
    _themeController          = TextEditingController(text: f?.theme ?? '');

    _publicationStatus = f?.publicationStatus ?? 'ONGOING';
    if (!['ONGOING', 'COMPLETED', 'HIATUS', 'CANCELLED'].contains(_publicationStatus)) {
      _publicationStatus = 'ONGOING';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _sourceMaterialController.dispose();
    _totalChaptersController.dispose();
    _coverUrlController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _mainShipController.dispose();
    _themeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    setState(() => _isSaving = true);

    try {
      final fanficToSave = FanfictionResponseDTO(
        idFanfic:          widget.fanfic?.idFanfic ?? 0,
        ao3Id:             widget.fanfic?.ao3Id,
        title:             _titleController.text.trim(),
        author:            _authorController.text.trim(),
        sourceMaterial:    _sourceMaterialController.text.trim(),
        totalChapters:     int.tryParse(_totalChaptersController.text),
        coverUrl:          _coverUrlController.text.trim(),
        description:       _descriptionController.text.trim(),
        publicationStatus: _publicationStatus,
        mainShip:          _mainShipController.text.trim().isEmpty
            ? null
            : _mainShipController.text.trim(),
        theme: _themeController.text.trim().isEmpty
            ? null
            : _themeController.text.trim(),
        tags: _tagsController.text.isNotEmpty
            ? _tagsController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList()
            : [],
      );

      final saved = await ref.read(catalogRepositoryProvider).saveOrUpdateFanfic(fanficToSave);

      if (widget.fanfic == null) {
        final userId = ref.read(userProfileProvider).value!.idUser;
        await ref.read(fanficJournalRepositoryProvider).saveRaw(
          FanficJournalRecordDTO(
            userId:   userId,
            fanficId: saved.idFanfic ?? 0,
            status:   'TBR',
          ).toJson(),
        );
        ref.invalidate(allJournalsProvider);
      }

      // Invalidamos el catálogo para que refleje el nuevo fanfic o edición
      ref.invalidate(allFanficsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(widget.fanfic == null
                  ? 'Fanfic añadido al diario'
                  : 'Cambios guardados'),
            ]),
            backgroundColor: AppColors.statusReading,
            behavior:        SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context, saved);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior:        SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isNew       = widget.fanfic == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNew ? 'Añadir fanfic' : 'Editar fanfic',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation:       0,
        foregroundColor: _accent,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            // ── Cover preview ───────────────────────────────────────────
            CoverPreviewHeader(
              coverUrlController: _coverUrlController,
              accentColor:        _accent,
              fallbackIcon:       Icons.favorite_rounded,
            ),
            const SizedBox(height: 8),

            // ── Información básica ──────────────────────────────────────
            FormSection(
              label:       'Información básica',
              accentColor: _accent,
              children: [
                AppTextField(
                  controller:  _titleController,
                  label:       'Título',
                  icon:        Icons.title_rounded,
                  accentColor: _accent,
                  isRequired:  true,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller:  _authorController,
                  label:       'Autor / Fandom creator',
                  icon:        Icons.person_outline_rounded,
                  accentColor: _accent,
                  isRequired:  true,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller:  _sourceMaterialController,
                  label:       'Fandom / Material de origen',
                  hint:        'ej. Harry Potter, LOTR…',
                  icon:        Icons.auto_awesome_rounded,
                  accentColor: _accent,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller:  _coverUrlController,
                  label:       'Enlace de la portada (URL)',
                  icon:        Icons.link_rounded,
                  accentColor: _accent,
                ),
              ],
            ),

            // ── Detalles ────────────────────────────────────────────────
            FormSection(
              label:       'Detalles',
              accentColor: _accent,
              children: [
                AppTextField(
                  controller:   _totalChaptersController,
                  label:        'Capítulos totales',
                  icon:         Icons.format_list_numbered_rounded,
                  accentColor:  _accent,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _publicationStatus,
                  decoration: InputDecoration(
                    labelText: 'Estado de publicación',
                    prefixIcon: const Icon(Icons.schedule_rounded, color: _accent),
                    filled: true,
                    fillColor: AppColors.card(context),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border(context)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _accent, width: 1.5),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'ONGOING', child: Text('En emisión')),
                    DropdownMenuItem(value: 'COMPLETED', child: Text('Completada')),
                    DropdownMenuItem(value: 'HIATUS', child: Text('En pausa (Hiatus)')),
                    DropdownMenuItem(value: 'CANCELLED', child: Text('Cancelada')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _publicationStatus = val);
                  },
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller:  _mainShipController,
                  label:       'Ship principal',
                  hint:        'ej. Drarry, Bakudeku...',
                  icon:        Icons.favorite_border_rounded,
                  accentColor: _accent,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller:  _themeController,
                  label:       'Tema / Género',
                  hint:        'ej. Angst, Fluff, Dark…',
                  icon:        Icons.category_rounded,
                  accentColor: _accent,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller:  _tagsController,
                  label:       'Tags',
                  hint:        'Slow burn, Enemies to lovers…',
                  icon:        Icons.local_offer_rounded,
                  accentColor: _accent,
                ),
              ],
            ),

            // ── Sinopsis ────────────────────────────────────────────────
            FormSection(
              label:       'Sinopsis',
              accentColor: _accent,
              children: [
                AppTextField(
                  controller:  _descriptionController,
                  label:       'Descripción',
                  icon:        Icons.notes_rounded,
                  accentColor: _accent,
                  maxLines:    6,
                ),
              ],
            ),

            // ── Save button ─────────────────────────────────────────────
            SaveButton(
              label:     isNew ? 'Añadir fanfic' : 'Guardar cambios',
              icon:      isNew ? Icons.add_rounded : Icons.save_rounded,
              color:     _accent,
              isLoading: _isSaving,
              onTap:     _save,
            ),
          ],
        ),
      ),
    );
  }
}