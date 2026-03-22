// lib/features/catalog/screens/libro_detalle_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../models/libro_model.dart';
import '../services/libro_service.dart';

class LibroDetalleScreen extends StatelessWidget {
  final LibroModel libro;

  const LibroDetalleScreen({super.key, required this.libro});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Detalle del libro',
            style: TextStyle(color: AppColors.text)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada grande
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: libro.portadaUrl != null
                    ? Image.network(
                        libro.portadaUrl!,
                        width: 150,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 150,
                          height: 220,
                          color: AppColors.surface,
                          child: const Icon(Icons.book,
                              size: 60, color: AppColors.textSecondary),
                        ),
                      )
                    : Container(
                        width: 150,
                        height: 220,
                        color: AppColors.surface,
                        child: const Icon(Icons.book,
                            size: 60, color: AppColors.textSecondary),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Título
            Text(
              libro.titulo,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Autor
            Text(
              libro.autor,
              style: const TextStyle(
                  color: AppColors.secondary, fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Datos
            if (libro.editorial != null)
              _datoFila('Editorial', libro.editorial!),
            if (libro.anioPublicacion != null)
              _datoFila('Año', '${libro.anioPublicacion}'),
            if (libro.genero != null)
              _datoFila('Género', libro.genero!),
            if (libro.isbn != null)
              _datoFila('ISBN', libro.isbn!),

            const SizedBox(height: 16),

            // Descripción
            if (libro.descripcion != null) ...[
              const Text(
                'Sinopsis',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                libro.descripcion!,
                style: const TextStyle(
                    color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 24),
            ],

            // Botón añadir al journal
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _guardarYAnadirJournal(context),
                icon: const Icon(Icons.bookmark_add, color: Colors.white),
                label: const Text('Añadir a mi journal',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _datoFila(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(valor,
                style: const TextStyle(color: AppColors.text)),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarYAnadirJournal(BuildContext context) async {
    final libroService = context.read<LibroService>();
    final libroGuardado = await libroService.guardarLibro(libro);

    if (libroGuardado != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Libro añadido a tu journal'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar el libro'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}