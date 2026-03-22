// lib/features/catalog/screens/libros_screen.dart
import 'package:between_pages/features/catalog/models/libro_model.dart';
import 'package:between_pages/features/catalog/screens/libro_detalles.dart';
import 'package:between_pages/features/catalog/services/libro_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';

class LibrosScreen extends StatefulWidget {
  const LibrosScreen({super.key});

  @override
  State<LibrosScreen> createState() => _LibrosScreenState();
}

class _LibrosScreenState extends State<LibrosScreen> {
  final _buscarController = TextEditingController();

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LibroService(),
      child: _LibrosScreenContent(buscarController: _buscarController),
    );
  }
}

class _LibrosScreenContent extends StatelessWidget {
  final TextEditingController buscarController;

  const _LibrosScreenContent({required this.buscarController});

  @override
  Widget build(BuildContext context) {
    final libroService = context.watch<LibroService>();

    return Column(
      children: [
        // Buscador
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: buscarController,
            style: const TextStyle(color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'Buscar libros...',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: libroService.cargando
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (valor) {
              if (valor.isNotEmpty) {
                context.read<LibroService>().buscarEnGoogleBooks(valor);
              }
            },
          ),
        ),

        // Error
        if (libroService.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(libroService.error!,
                style: const TextStyle(color: AppColors.error)),
          ),

        // Resultados
        Expanded(
          child: libroService.resultados.isEmpty && !libroService.cargando
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book_outlined,
                          size: 64, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text('Busca un libro para empezar',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: libroService.resultados.length,
                  itemBuilder: (context, index) {
                    final libro = libroService.resultados[index];
                    return _LibroCard(libro: libro);
                  },
                ),
        ),
      ],
    );
  }
}

class _LibroCard extends StatelessWidget {
  final LibroModel libro;

  const _LibroCard({required this.libro});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LibroDetalleScreen(libro: libro),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Portada
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: libro.portadaUrl != null
                    ? Image.network(
                        libro.portadaUrl!,
                        width: 60,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderPortada(),
                      )
                    : _placeholderPortada(),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      libro.titulo,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      libro.autor,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                    if (libro.anioPublicacion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${libro.anioPublicacion}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                    if (libro.genero != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          libro.genero!,
                          style: const TextStyle(
                              color: AppColors.primary, fontSize: 11),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderPortada() {
    return Container(
      width: 60,
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.book, color: AppColors.textSecondary),
    );
  }
}

