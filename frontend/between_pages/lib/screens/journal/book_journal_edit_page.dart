import 'package:between_pages/models/journal/book_journal_record_dto.dart';
import 'package:between_pages/models/journal/book_journal_response_dto.dart';
import 'package:between_pages/repositories/auth_repository.dart';
import 'package:between_pages/repositories/book_journal_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BookJournalEditPage extends ConsumerStatefulWidget {
  final BookJournalResponseDto journal;

  const BookJournalEditPage({super.key, required this.journal});

  @override
  ConsumerState<BookJournalEditPage> createState() =>
      _BookJournalEditPageState();
}

class _BookJournalEditPageState extends ConsumerState<BookJournalEditPage> {
  late String _status;
  late int? _currentPage;
  late int? _rating;
  late String? _readingFormat;
  late String? _personalNotes;
  late String? _emotions;
  late String? _favoriteQuotes;
  bool _isLoading = false;

  final List<String> _statusOptions = [
    'Pendiente',
    'Leyendo',
    'Terminado',
    'Abandonado',
  ];
  final List<String> _formatOptions = ['Físico', 'Ebook', 'Audiolibro'];

  @override
  void initState() {
    super.initState();
    final j = widget.journal;
    _status = _mapStatusToUi(j.status ?? 'PENDING');
    _currentPage = j.currentPage;
    _rating = j.rating;
    _readingFormat = j.readingFormat;
    _personalNotes = j.personalNotes;
    _emotions = j.emotions?.join(', ');
    _favoriteQuotes = j.favoriteQuotes;
  }

  String _mapStatusToUi(String status) {
    return switch (status) {
      'PENDING' => 'Pendiente',
      'READING' => 'Leyendo',
      'FINISHED' => 'Terminado',
      'DROPPED' => 'Abandonado',
      _ => status,
    };
  }

  String _mapStatusToDb(String status) {
    return switch (status) {
      'Pendiente' => 'PENDING',
      'Leyendo' => 'READING',
      'Terminado' => 'FINISHED',
      'Abandonado' => 'DROPPED',
      _ => status,
    };
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final authRepository = ref.read(authRepositoryProvider);
      final journalRepository = ref.read(bookJournalRepositoryProvider);
      final user = await authRepository.getUserProfile();

      final book = widget.journal.book;
      final dto = BookJournalRecordDTO(
        userId: user.idUser,
        bookId: book.idBook,
        googleBooksId: book.googleBooksId,
        title: book.title,
        author: book.author,
        isbn: book.isbn,
        publisher: book.publisher,
        description: book.description,
        coverUrl: book.coverUrl,
        genre: book.genre,
        publicationYear: book.publishYear,
        status: _mapStatusToDb(_status),
        currentPage: _currentPage,
        rating: _rating,
        readingFormat: _readingFormat,
        emotions: _emotions?.isNotEmpty == true
            ? _emotions!.split(',').map((e) => e.trim()).toList()
            : null,
        favoriteQuotes: _favoriteQuotes,
        personalNotes: _personalNotes,
        startDate: widget.journal.startDate,
        endDate: _status == 'Terminado'
            ? _formatDate(DateTime.now())
            : widget.journal.endDate,
      );

      await journalRepository.saveOrUpdate(dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal actualizado correctamente')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final book = widget.journal.book;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Journal'),
        actions: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            TextButton(onPressed: _save, child: const Text('Guardar')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada y título
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: book.coverUrl != null
                      ? CachedNetworkImage(
                          imageUrl: book.coverUrl!,
                          width: 100,
                          height: 150,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 100,
                          height: 150,
                          color: colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.book, size: 40),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.author ?? 'Autor desconocido',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (book.genre != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          book.genre!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Estado
            _buildSectionTitle('Estado de lectura'),
            Wrap(
              spacing: 8,
              children: _statusOptions.map((status) {
                final isSelected = _status == status;
                return ChoiceChip(
                  label: Text(status),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _status = status),
                  selectedColor: colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: isSelected ? colorScheme.onPrimaryContainer : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Progreso
            _buildSectionTitle('Progreso'),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    label: 'Página actual',
                    value: _currentPage,
                    onChanged: (v) => setState(() => _currentPage = v),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField(
                    label: 'Valoración (1-10)',
                    value: _rating,
                    onChanged: (v) => setState(() => _rating = v),
                    max: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Formato
            _buildSectionTitle('Formato de lectura'),
            Wrap(
              spacing: 8,
              children: _formatOptions.map((format) {
                final isSelected = _readingFormat == format;
                return ChoiceChip(
                  label: Text(format),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _readingFormat = format),
                  selectedColor: colorScheme.secondaryContainer,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Notas personales
            _buildSectionTitle('Notas personales'),
            TextField(
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Escribe tus pensamientos sobre este libro...',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _personalNotes),
              onChanged: (v) => _personalNotes = v,
            ),
            const SizedBox(height: 24),

            // Emociones
            _buildSectionTitle('Emociones'),
            TextField(
              decoration: const InputDecoration(
                hintText:
                    '¿Cómo te hizo sentir? (ej: Feliz, Triste, Emocionado)',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _emotions),
              onChanged: (v) => _emotions = v,
            ),
            const SizedBox(height: 24),

            // Frases favoritas
            _buildSectionTitle('Frases favoritas'),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Cita tus frases favoritas del libro...',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _favoriteQuotes),
              onChanged: (v) => _favoriteQuotes = v,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required int? value,
    required Function(int?) onChanged,
    int max = 9999,
  }) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      controller: TextEditingController(text: value?.toString() ?? ''),
      onChanged: (v) {
        final num = int.tryParse(v);
        if (num != null && num >= 0 && num <= max) {
          onChanged(num);
        } else if (v.isEmpty) {
          onChanged(null);
        }
      },
    );
  }
}
