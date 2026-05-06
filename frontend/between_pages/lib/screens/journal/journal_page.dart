import 'package:between_pages/models/journal/book_journal_response_dto.dart';
import 'package:between_pages/models/journal/manga_journal_response_dto.dart';
import 'package:between_pages/providers/journal/book_journal_provider.dart';
import 'package:between_pages/providers/journal/fanfic_journal_provider.dart';
import 'package:between_pages/models/journal/fanfic_journal_response_dto.dart';
import 'package:between_pages/providers/journal/manga_journal_provider.dart';
import 'package:between_pages/widgets/common/empty_state.dart';
import 'package:between_pages/widgets/journal/journal_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

/// Página principal del Journal con tabs para Libros, Mangas y Fanfics.
/// Usa widgets genéricos para eliminar duplicación entre tipos de contenido.
class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Journal',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          backgroundColor: colorScheme.surface,
          actions: [
            IconButton(
              icon: const Icon(Icons.psychology_outlined),
              tooltip: 'Segundo Cerebro',
              onPressed: () => context.push('/second-brain'),
            ),
          ],
          bottom: TabBar(
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            tabs: const [
              Tab(text: 'Libros'),
              Tab(text: 'Mangas'),
              Tab(text: 'Fanfics'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _BooksTab(),
            _MangaTab(),
            _FanficsTab(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TABS ESPECÍFICAS (solo configuran el genérico)
// ─────────────────────────────────────────────────────────────────────────────

class _BooksTab extends StatelessWidget {
  const _BooksTab();

  @override
  Widget build(BuildContext context) {
    return JournalTab<BookJournalResponseDto>(
      provider: bookJournalProvider,
      extractStatus: (j) => j.status,
      toItemData: (j) => JournalItemData(
        id: j.id,
        title: j.book.title,
        coverUrl: j.book.coverUrl,
        subtitle: j.currentPage != null && j.currentPage! > 0
            ? 'Pág. ${j.currentPage}'
            : null,
        ownership: j.ownership,
        route: j.status == 'READING'
            ? '/journal/book/progress'
            : '/journal/book/edit',
        extra: j,
      ),
      fallbackIcon: Icons.book,
      emptyTitle: 'No hay libros en tu Journal',
      emptySubtitle: 'Busca libros y añádelos para empezar a leer',
    );
  }
}

class _MangaTab extends StatelessWidget {
  const _MangaTab();

  @override
  Widget build(BuildContext context) {
    return JournalTab<MangaJournalResponseDTO>(
      provider: mangaJournalProvider,
      extractStatus: (j) => j.status ?? 'PENDING',
      toItemData: (j) {
        final manga = j.manga;
        return JournalItemData(
          id: j.id,
          title: manga?.title ?? 'Sin título',
          coverUrl: manga?.coverUrl,
          subtitle: (j.currentChapter ?? 0) > 0
              ? 'Cap. ${j.currentChapter}'
              : null,
          ownership: j.ownership,
          route: '/journal/manga/edit',
          extra: j,
        );
      },
      fallbackIcon: Icons.auto_stories,
      emptyTitle: 'No hay mangas en tu Journal',
      emptySubtitle: 'Busca manga y añádelos para empezar a leer',
    );
  }
}

class _FanficsTab extends StatelessWidget {
  const _FanficsTab();

  @override
  Widget build(BuildContext context) {
    return JournalTab<FanficJournalResponseDTO>(
      provider: fanficJournalProvider,
      extractStatus: (j) => j.status ?? 'PENDING',
      toItemData: (j) {
        final fanfic = j.fanfic;
        return JournalItemData(
          id: j.id,
          title: fanfic?.title ?? 'Sin título',
          coverUrl: fanfic?.coverUrl,
          subtitle: (j.currentChapter ?? 0) > 0
              ? 'Cap. ${j.currentChapter}'
              : null,
          ownership: null, // Fanfics don't have ownership
          route: '/journal/fanfic/edit',
          extra: j,
        );
      },
      fallbackIcon: Icons.favorite,
      emptyTitle: 'No hay fanfics en tu Journal',
      emptySubtitle: 'Busca fanfics y añádelos para empezar a leer',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET GENÉRICO JOURNAL TAB<T>
// Elimina duplicación entre tabs de libros, manga y fanfics.
// ─────────────────────────────────────────────────────────────────────────────

class JournalTab<T> extends ConsumerWidget {
  final ProviderListenable<AsyncValue<List<T>>> provider;
  final String Function(T) extractStatus;
  final JournalItemData Function(T) toItemData;
  final IconData fallbackIcon;
  final String emptyTitle;
  final String? emptySubtitle;

  const JournalTab({
    super.key,
    required this.provider,
    required this.extractStatus,
    required this.toItemData,
    required this.fallbackIcon,
    required this.emptyTitle,
    this.emptySubtitle,
  });

  static const _statusConfig = <String, ({String label, Color color})>{
    'READING': (label: 'Leyendo', color: Colors.green),
    'PENDING': (label: 'Pendientes', color: Colors.orange),
    'PAUSED': (label: 'Pausados', color: Colors.purple),
    'FINISHED': (label: 'Terminados', color: Colors.blue),
    'DROPPED': (label: 'Abandonados', color: Colors.red),
    'TBR': (label: 'Por leer', color: Colors.teal),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(provider);

    return asyncValue.when(
      data: (journals) {
        if (journals.isEmpty) {
          return EmptyState(
            icon: fallbackIcon,
            title: emptyTitle,
            subtitle: emptySubtitle,
          );
        }

        final grouped = _groupByStatus(journals);
        final orderedStatuses = _statusConfig.keys
            .where((s) => grouped.containsKey(s) && grouped[s]!.isNotEmpty)
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orderedStatuses.length,
          itemBuilder: (context, index) {
            final status = orderedStatuses[index];
            final config = _statusConfig[status]!;
            final items = grouped[status]!;
            return _StatusSection(
              title: config.label,
              color: config.color,
              count: items.length,
              children: items.map(toItemData).map((data) => JournalItemCard(
                item: data,
                fallbackIcon: fallbackIcon,
              )).toList(),
            );
          },
        );
      },
      loading: () => const _JournalShimmer(),
      error: (error, _) => EmptyState(
        icon: Icons.error_outline,
        title: 'Error al cargar',
        subtitle: error.toString(),
      ),
    );
  }

  Map<String, List<T>> _groupByStatus(List<T> journals) {
    final grouped = <String, List<T>>{};
    for (final journal in journals) {
      final status = extractStatus(journal);
      grouped.putIfAbsent(status, () => []).add(journal);
    }
    return grouped;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECCIÓN DE ESTADO (ej: "Leyendo", "Pendientes")
// ─────────────────────────────────────────────────────────────────────────────

class _StatusSection extends StatelessWidget {
  final String title;
  final Color color;
  final int count;
  final List<Widget> children;

  const _StatusSection({
    required this.title,
    required this.color,
    required this.count,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: children,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHIMMER LOADING (mejor UX que CircularProgressIndicator)
// ─────────────────────────────────────────────────────────────────────────────

class _JournalShimmer extends StatelessWidget {
  const _JournalShimmer();

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: baseColor.withValues(alpha: 0.5),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, sectionIndex) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de sección shimmer
              Container(
                width: 120,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              // Cards shimmer
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 110,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 90,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
