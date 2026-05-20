import 'package:between_pages/core/theme/app_colors.dart';
import 'package:between_pages/features/catalog/application/repositories/catalog_repository.dart';
import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/catalog/presentation/widgets/edit_form_widgets.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/domain/manga_journal_record_dto.dart';
import 'package:between_pages/features/profile/application/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MangaEditPage extends ConsumerStatefulWidget {
  final MangaResponseDTO? manga;
  const MangaEditPage({super.key, this.manga});

  @override
  ConsumerState<MangaEditPage> createState() => _MangaEditPageState();
}

class _MangaEditPageState extends ConsumerState<MangaEditPage> {
  static const _accent = AppColors.colorManga; // 0xFFE8A87C

  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _demographicController;
  late final TextEditingController _totalChaptersController;
  late final TextEditingController _totalVolumesController;
  late final TextEditingController _coverUrlController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _genreController;

  @override
  void initState() {
    super.initState();
    final m = widget.manga;
    _titleController          = TextEditingController(text: m?.title ?? '');
    _authorController         = TextEditingController(text: m?.author ?? '');
    _demographicController    = TextEditingController(text: m?.demographic ?? '');
    _totalChaptersController  = TextEditingController(text: m?.totalChapters?.toString() ?? '');
    _totalVolumesController   = TextEditingController(text: m?.totalVolumes?.toString() ?? '');
    _coverUrlController       = TextEditingController(text: m?.coverUrl ?? '');
    _descriptionController    = TextEditingController(text: m?.description ?? '');
    _genreController          = TextEditingController(text: m?.genres.join(', ') ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _demographicController.dispose();
    _totalChaptersController.dispose();
    _totalVolumesController.dispose();
    _coverUrlController.dispose();
    _descriptionController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(catalogRepositoryProvider);
      final mangaToSave = MangaResponseDTO(
        idManga:           widget.manga?.idManga ?? 0,
        malId:             widget.manga?.malId,
        title:             _titleController.text.trim(),
        author:            _authorController.text.trim(),
        demographic:       _demographicController.text.trim(),
        totalChapters:     int.tryParse(_totalChaptersController.text),
        totalVolumes:      int.tryParse(_totalVolumesController.text),
        coverUrl:          _coverUrlController.text.trim(),
        description:       _descriptionController.text.trim(),
        publicationStatus: widget.manga?.publicationStatus ?? 'Publishing',
        genres: _genreController.text.isNotEmpty
            ? _genreController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList()
            : [],
      );

      final saved = await repo.saveOrUpdateManga(mangaToSave);

      if (widget.manga == null) {
        final userId = ref.read(userProfileProvider).value!.idUser;
        await ref.read(mangaJournalRepositoryProvider).saveRaw(
          MangaJournalRecordDTO(
            userId:  userId,
            mangaId: saved.idManga,
            status:  'TBR',
          ).toJson(),
        );
        ref.invalidate(journalProvider(JournalType.manga));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(widget.manga == null
                  ? 'Manga añadido al diario'
                  : 'Cambios guardados'),
            ]),
            backgroundColor: AppColors.statusReading,
            behavior:        SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    final isNew       = widget.manga == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNew ? 'Añadir manga' : 'Editar manga',
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
              fallbackIcon:       Icons.menu_book_rounded,
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
                  label:       'Autor / Mangaka',
                  icon:        Icons.person_outline_rounded,
                  accentColor: _accent,
                  isRequired:  true,
                ),
              ],
            ),

            // ── Detalles ────────────────────────────────────────────────
            FormSection(
              label:       'Detalles',
              accentColor: _accent,
              children: [
                TwoColumnRow(
                  left: AppTextField(
                    controller:   _totalChaptersController,
                    label:        'Capítulos',
                    icon:         Icons.format_list_numbered_rounded,
                    accentColor:  _accent,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  right: AppTextField(
                    controller:   _totalVolumesController,
                    label:        'Volúmenes',
                    icon:         Icons.library_books_rounded,
                    accentColor:  _accent,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller:  _demographicController,
                  label:       'Demografía',
                  hint:        'Seinen, Shounen, Josei…',
                  icon:        Icons.group_rounded,
                  accentColor: _accent,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller:  _genreController,
                  label:       'Géneros',
                  hint:        'Acción, Fantasy, Romance…',
                  icon:        Icons.category_rounded,
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
              label:     isNew ? 'Añadir manga' : 'Guardar cambios',
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