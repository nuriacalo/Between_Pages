import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:between_pages/models/journal/book_journal_response_dto.dart';
import 'package:between_pages/models/journal/manga_journal_response_dto.dart';
import 'package:between_pages/models/journal/fanfic_journal_response_dto.dart';

import 'package:between_pages/providers/dashboard/unified_dashboard_provider.dart';

class UnifiedReadingCarousel extends ConsumerWidget {
  const UnifiedReadingCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unifiedState = ref.watch(unifiedReadingDashboardProvider);

    return unifiedState.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Text('No estás leyendo nada actualmente. ¡Explora el catálogo!'),
          );
        }
        
        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              
              String title = 'Sin título';
              String? coverUrl;
              String type = 'Desconocido';

              // Usamos chequeo de tipos para extraer los datos de cada modelo
              if (item is BookJournalResponseDto) {
                title = item.book.title;
                coverUrl = item.book.coverUrl;
                type = 'Libro';
              } else if (item is MangaJournalResponseDTO) {
                title = item.manga?.title ?? 'Manga';
                coverUrl = item.manga?.coverUrl;
                type = 'Manga';
              } else if (item is FanficJournalResponseDTO) {
                title = item.fanfic.title ?? 'Fanfic';
                coverUrl = item.fanfic.coverUrl;
                type = 'Fanfic';
              }

              return _buildCard(context, title, coverUrl, type);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error al cargar lecturas')),
    );
  }

  Widget _buildCard(BuildContext context, String title, String? coverUrl, String type) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: coverUrl != null
                  ? CachedNetworkImage(imageUrl: coverUrl, fit: BoxFit.cover, width: 130)
                  : Container(color: Colors.grey.shade300, width: 130, child: const Icon(Icons.book)),
            ),
          ),
          const SizedBox(height: 8),
          Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(type, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}