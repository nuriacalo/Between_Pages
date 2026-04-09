import 'package:between_pages/models/catalog/book_response_dto.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BookDetailPage extends StatelessWidget {
  final BookResponseDTO book;

  const BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
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
            
            // Título y Autor
            Center(
              child: Text(book.title, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(book.author, style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Sinopsis
            Text('Sinopsis', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              book.description ?? 'No hay sinopsis disponible para este libro.',
              style: textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Detalles técnicos
            if (book.genre != null) _buildDetailRow('Género', book.genre!, context),
            if (book.publishYear != null) _buildDetailRow('Año de publicación', book.publishYear.toString(), context),
            if (book.publisher != null) _buildDetailRow('Editorial', book.publisher!, context),
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
          Expanded(child: Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
        ],
      ),
    );
  }
}