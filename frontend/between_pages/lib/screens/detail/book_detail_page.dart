import 'package:between_pages/models/catalog/book_response_dto.dart';
import 'package:between_pages/models/journal/book_journal_record_dto.dart';
import 'package:between_pages/repositories/auth_repository.dart';
import 'package:between_pages/repositories/book_journal_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookDetailPage extends ConsumerStatefulWidget {
  final BookResponseDTO book;

  const BookDetailPage({super.key, required this.book});

  @override
  ConsumerState<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends ConsumerState<BookDetailPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final book = widget.book;

    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada en grande
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: book.coverUrl!,
                        height: 250,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 250,
                        width: 170,
                        color: colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.book, size: 80),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Botón para añadir al journal
            Center(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _showAddToJournalDialog(),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: const Text('Añadir a mi journal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Título y Autor
            Center(
              child: Text(
                book.title,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                book.author,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Sinopsis
            Text(
              'Sinopsis',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.description ?? 'No hay sinopsis disponible para este libro.',
              style: textTheme.bodyMedium?.copyWith(height: 1.5),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Detalles técnicos
            if (book.genre != null)
              _buildDetailRow('Género', book.genre!, context),
            if (book.publishYear != null)
              _buildDetailRow(
                'Año de publicación',
                book.publishYear.toString(),
                context,
              ),
            if (book.publisher != null)
              _buildDetailRow('Editorial', book.publisher!, context),
            if (book.isbn != null) _buildDetailRow('ISBN', book.isbn!, context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToJournalDialog() {
    final statuses = [
      'Pendiente',
      'Leyendo',
      'Pausado',
      'Terminado',
      'Abandonado'
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses
              .map(
                (status) => ListTile(
                  title: Text(status),
                  leading: Icon(_getStatusIcon(status)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addToJournal(status);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _addToJournal(String status) async {
    setState(() => _isLoading = true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final journalRepository = ref.read(bookJournalRepositoryProvider);

      final user = await authRepository.getUserProfile();

      final dto = BookJournalRecordDTO(
        userId: user.idUser,
        bookId: widget.book.idBook > 0 ? widget.book.idBook : null,
        googleBooksId: widget.book.googleBooksId.isNotEmpty
            ? widget.book.googleBooksId
            : null,
        title: widget.book.title.isNotEmpty ? widget.book.title : null,
        author: widget.book.author.isNotEmpty ? widget.book.author : null,
        isbn: widget.book.isbn,
        publisher: widget.book.publisher,
        description: widget.book.description,
        coverUrl: widget.book.coverUrl,
        genre: widget.book.genre,
        publicationYear: widget.book.publishYear,
        status: status,
        startDate: status == 'Leyendo' ? _formatDate(DateTime.now()) : null,
      );

      await journalRepository.saveOrUpdate(dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Añadido al journal correctamente'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pendiente':
        return Icons.bookmark_border;
      case 'Leyendo':
        return Icons.menu_book;
      case 'Terminado':
        return Icons.check_circle;
      case 'Pausado':
        return Icons.pause_circle_outline;
      case 'Abandonado':
        return Icons.cancel;
      default:
        return Icons.book;
    }
  }

  String _formatDate(DateTime date) {
    // Formato yyyy-MM-dd para LocalDate de Java
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
