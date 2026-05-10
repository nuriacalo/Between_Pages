
import 'package:between_pages/features/profile/application/providers/user_provider.dart';
import 'package:between_pages/features/catalog/application/repositories/book_search_repository.dart';
import 'package:between_pages/features/catalog/domain/book_response_dto.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/journal/domain/book_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/journal_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookEditPage extends ConsumerStatefulWidget {
  final BookResponseDTO? book; // Null para crear un nuevo libro

  const BookEditPage({super.key, this.book});

  @override
  ConsumerState<BookEditPage> createState() => _BookEditPageState();
}

class _BookEditPageState extends ConsumerState<BookEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _pageCountController;
  late TextEditingController _coverUrlController;
  late TextEditingController _isbnController;
  late TextEditingController _publisherController;
  late TextEditingController _publishYearController;
  late TextEditingController _descriptionController;
  late TextEditingController _genreController;

  @override
  void initState() {
    super.initState();
    final book = widget.book;
    _titleController = TextEditingController(text: book?.title ?? '');
    _authorController = TextEditingController(text: book?.author ?? '');
    _pageCountController =
        TextEditingController(text: book?.pageCount?.toString() ?? '');
    _coverUrlController = TextEditingController(text: book?.coverUrl ?? '');
    _isbnController = TextEditingController(text: book?.isbn ?? '');
    _publisherController = TextEditingController(text: book?.publisher ?? '');
    _publishYearController =
        TextEditingController(text: book?.publishYear?.toString() ?? '');
    _descriptionController =
        TextEditingController(text: book?.description ?? '');
    _genreController = TextEditingController(text: book?.genres.join(', ') ?? '');
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

  Future<void> _saveBookAndJournal() async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Paso 1: Crear o actualizar el libro en el catálogo
      final bookRepo = ref.read(bookSearchRepositoryProvider);
      final bookToSave = BookResponseDTO(
        idBook: widget.book?.idBook ?? 0,
        googleBooksId: widget.book?.googleBooksId ?? '',
        title: _titleController.text,
        author: _authorController.text,
        pageCount: int.tryParse(_pageCountController.text),
        coverUrl: _coverUrlController.text,
        isbn: _isbnController.text,
        publisher: _publisherController.text,
        publishYear: int.tryParse(_publishYearController.text),
        description: _descriptionController.text,
        genres: _genreController.text.isNotEmpty
            ? _genreController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
            : [],
        bookType: widget.book?.bookType ?? 'STANDALONE',
      );

      final savedBook = await bookRepo.saveOrUpdateBook(bookToSave);

      // Paso 2: Si es un libro nuevo, añadirlo al journal del usuario
      if (widget.book == null) {
        final journalRepo = ref.read(bookJournalRepositoryProvider);
        final userId = ref.read(userProfileProvider).value!.idUser;

        final journalDto = BookJournalRecordDTO(
          userId: userId,
          bookId: savedBook.idBook,
          status: 'TBR', // Estado inicial por defecto
        );
        await journalRepo.saveRaw(journalDto.toJson());
        ref.invalidate(journalProvider(JournalType.book));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Libro guardado y añadido al diario con éxito'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context, savedBook);
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $errorMessage'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
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
        title: Text(widget.book == null ? 'Añadir libro' : 'Editar libro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveBookAndJournal,
            tooltip: 'Guardar',
          ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildTextField(_titleController, 'Título', isRequired: true),
                  _buildTextField(_authorController, 'Autor', isRequired: true),
                  _buildTextField(_pageCountController, 'Número de páginas',
                      keyboardType: TextInputType.number),
                  _buildTextField(_publishYearController, 'Año de publicación',
                      keyboardType: TextInputType.number),
                  _buildTextField(_coverUrlController, 'URL de la portada',
                      keyboardType: TextInputType.url),
                  _buildTextField(_isbnController, 'ISBN'),
                  _buildTextField(_publisherController, 'Editorial'),
                  _buildTextField(_genreController, 'Géneros (separados por coma)'),
                  _buildTextField(_descriptionController, 'Descripción',
                      maxLines: 5),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isRequired = false,
    TextInputType? keyboardType,
    int? maxLines = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDark
              ? const Color(0xFF3D2D30)
              : const Color(0xFFFDF5F2),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Este campo es requerido';
          }
          return null;
        },
        inputFormatters: keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
      ),
    );
  }
}
