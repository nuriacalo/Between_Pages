import 'package:between_pages/core/theme/app_colors.dart';
import 'package:between_pages/features/catalog/application/repositories/catalog_repository.dart';
import 'package:between_pages/features/catalog/application/providers/all_books_provider.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/catalog/presentation/widgets/edit_form_widgets.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/journal/domain/records/book_journal_record_dto.dart';
import 'package:between_pages/features/profile/application/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookEditPage extends ConsumerStatefulWidget {
  final BookResponseDTO? book;
  const BookEditPage({super.key, this.book});

  @override
  ConsumerState<BookEditPage> createState() => _BookEditPageState();
}

class _BookEditPageState extends ConsumerState<BookEditPage> {
  static const _accent = AppColors.colorLibro; // 0xFF7F8C95

  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _pageCountController;
  late final TextEditingController _coverUrlController;
  late final TextEditingController _isbnController;
  late final TextEditingController _publisherController;
  late final TextEditingController _publishYearController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _genreController;

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _titleController       = TextEditingController(text: b?.title ?? '');
    _authorController      = TextEditingController(text: b?.author ?? '');
    _pageCountController   = TextEditingController(text: b?.pageCount?.toString() ?? '');
    _coverUrlController    = TextEditingController(text: b?.coverUrl ?? '');
    _isbnController        = TextEditingController(text: b?.isbn ?? '');
    _publisherController   = TextEditingController(text: b?.publisher ?? '');
    _publishYearController = TextEditingController(text: b?.publishYear?.toString() ?? '');
    _descriptionController = TextEditingController(text: b?.description ?? '');
    _genreController       = TextEditingController(text: b?.genres.join(', ') ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pageCountController.dispose();
    _coverUrlController.dispose();
    _isbnController.dispose();
    _publisherController.dispose();
    _publishYearController.dispose();
    _descriptionController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    setState(() => _isSaving = true);

    try {
      final bookToSave = BookResponseDTO(
        idBook:       widget.book?.idBook ?? 0,
        googleBooksId: widget.book?.googleBooksId ?? '',
        title:        _titleController.text.trim(),
        author:       _authorController.text.trim(),
        pageCount:    int.tryParse(_pageCountController.text),
        coverUrl:     _coverUrlController.text.trim(),
        isbn:         _isbnController.text.trim(),
        publisher:    _publisherController.text.trim(),
        publishYear:  int.tryParse(_publishYearController.text),
        description:  _descriptionController.text.trim(),
        genres: _genreController.text.isNotEmpty
            ? _genreController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList()
            : [],
        bookType: widget.book?.bookType ?? 'STANDALONE',
      );

      final savedBook = await ref.read(catalogRepositoryProvider).saveOrUpdateBook(bookToSave);

      if (widget.book == null) {
        final userId = ref.read(userProfileProvider).value!.idUser;
        await ref.read(bookJournalRepositoryProvider).saveRaw(
          BookJournalRecordDTO(
            userId: userId,
            bookId: savedBook.idBook,
            status: 'TBR',
          ).toJson(),
        );
        ref.invalidate(allJournalsProvider);
      }

      // Invalidamos el catálogo para que refleje el nuevo libro o edición
      ref.invalidate(allBooksProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(widget.book == null
                  ? 'Libro añadido al diario'
                  : 'Cambios guardados'),
            ]),
            backgroundColor: AppColors.statusReading,
            behavior:        SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context, savedBook);
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
    final isNew       = widget.book == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNew ? 'Añadir libro' : 'Editar libro',
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
              fallbackIcon:       Icons.book_rounded,
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
                  label:       'Autor',
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
                    controller:   _pageCountController,
                    label:        'Páginas',
                    icon:         Icons.auto_stories_rounded,
                    accentColor:  _accent,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  right: AppTextField(
                    controller:   _publishYearController,
                    label:        'Año',
                    icon:         Icons.calendar_today_rounded,
                    accentColor:  _accent,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller:  _isbnController,
                  label:       'ISBN',
                  icon:        Icons.qr_code_2_rounded,
                  accentColor: _accent,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller:  _publisherController,
                  label:       'Editorial',
                  icon:        Icons.business_rounded,
                  accentColor: _accent,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller:  _genreController,
                  label:       'Géneros',
                  hint:        'Fantasía, Aventura, Magia…',
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
              label:     isNew ? 'Añadir libro' : 'Guardar cambios',
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