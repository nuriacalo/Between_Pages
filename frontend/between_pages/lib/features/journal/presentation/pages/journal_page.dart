import 'package:between_pages/core/widgets/empty_state.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/journal/domain/responses/base_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/book_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/fanfic_journal_response_dto.dart';
import 'package:between_pages/features/journal/domain/responses/manga_journal_response_dto.dart';
import 'package:between_pages/features/journal/presentation/widgets/journal_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:between_pages/l10n/app_localizations.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.journalTitle, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          backgroundColor: colorScheme.surface,
          actions: [
            IconButton(
              icon: const Icon(Icons.note_alt_outlined),
              tooltip: l10n.secondBrainTooltip,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad en desarrollo 🚧')),
                );
              },
            ),
          ],
          bottom: TabBar(
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 3.0,
            dividerColor: colorScheme.outlineVariant.withOpacity(0.3),
            tabs: [
              Tab(text: l10n.tabBooks),
              Tab(text: l10n.tabMangas),
              Tab(text: l10n.tabFanfics),
            ],
          ),
        ),
        body: TabBarView(
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

class _BooksTab extends StatelessWidget {
  const _BooksTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return JournalTab<BaseJournalResponseDTO>(
      provider: journalProvider(JournalType.book),
      extractStatus: (j) => j.status,
      toItemData: (j) {
        final journal = j as BookJournalResponseDto;
        return JournalItemData(
          id: journal.id,
          title: journal.book.title,
          coverUrl: journal.book.coverUrl,
          subtitle: journal.currentPage != null && journal.currentPage! > 0 ? 'Pág. ${journal.currentPage}' : null,
          ownership: journal.ownership,
          route: '/journal/book/edit', // Always navigate to edit page
          extra: journal,
        );
      },
      fallbackIcon: Icons.book,
      emptyTitle: l10n.emptyJournalBooksTitle,
      emptySubtitle: l10n.emptyJournalBooksSubtitle,
    );
  }
}

class _MangaTab extends StatelessWidget {
  const _MangaTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return JournalTab<BaseJournalResponseDTO>(
      provider: journalProvider(JournalType.manga),
      extractStatus: (j) => j.status,
      toItemData: (j) {
        final journal = j as MangaJournalResponseDTO;
        final manga = journal.manga;
        return JournalItemData(
          id: journal.id,
          title: manga?.title ?? 'Sin título',
          coverUrl: manga?.coverUrl,
          subtitle: (journal.currentChapter ?? 0) > 0 ? 'Cap. ${journal.currentChapter ?? 0}' : null,
          ownership: journal.ownership,
          route: '/journal/manga/edit', // Always navigate to edit page
          extra: journal,
        );
      },
      fallbackIcon: Icons.auto_stories,
      emptyTitle: l10n.emptyJournalMangasTitle,
      emptySubtitle: l10n.emptyJournalMangasSubtitle,
    );
  }
}

class _FanficsTab extends StatelessWidget {
  const _FanficsTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return JournalTab<BaseJournalResponseDTO>(
      provider: journalProvider(JournalType.fanfic),
      extractStatus: (j) => j.status,
      toItemData: (j) {
        final journal = j as FanficJournalResponseDTO;
        final fanfic = journal.fanfic;
        return JournalItemData(
          id: journal.id,
          title: fanfic.title ?? 'Sin título',
          coverUrl: fanfic.coverUrl,
          subtitle: (journal.currentChapter ?? 0) > 0 ? 'Cap. ${journal.currentChapter ?? 0}' : null,
          ownership: null,
          route: '/journal/fanfic/edit',
          extra: journal,
        );
      },
      fallbackIcon: Icons.favorite,
      emptyTitle: l10n.emptyJournalFanficsTitle,
      emptySubtitle: l10n.emptyJournalFanficsSubtitle,
    );
  }
}

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncValue = ref.watch(provider);

    final statusConfig = <String, ({String label, Color color})>{
      'READING': (label: l10n.statusReading, color: Colors.green),
      'TBR': (label: l10n.statusTBR, color: Colors.teal),
      'PAUSED': (label: l10n.statusPaused, color: Colors.orange),
      'FINISHED': (label: l10n.statusFinished, color: Colors.blue),
      'WISHLIST': (label: l10n.statusWishlist, color: Colors.purple),
      'DROPPED': (label: l10n.statusDropped, color: Colors.red),
    };

    return asyncValue.when(
      data: (journals) {
        if (journals.isEmpty) {
          return EmptyState(
            icon: fallbackIcon,
            title: emptyTitle,
            subtitle: emptySubtitle,
            actionLabel: l10n.findSomethingToRead, 
            onAction: () => GoRouter.of(context).go('/search'),
          );
        }

        final grouped = _groupByStatus(journals);
        final orderedStatuses = statusConfig.keys.where((s) => grouped.containsKey(s) && grouped[s]!.isNotEmpty).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orderedStatuses.length,
          itemBuilder: (context, index) {
            final status = orderedStatuses[index];
            final config = statusConfig[status]!;
            final items = grouped[status]!;
            return _StatusSection(
              title: config.label,
              color: config.color,
              count: items.length,
              children: items.map(toItemData).map((data) => JournalItemCard(item: data, fallbackIcon: fallbackIcon)).toList(),
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

class _StatusSection extends StatelessWidget {
  final String title;
  final Color color;
  final int count;
  final List<Widget> children;

  const _StatusSection({required this.title, required this.color, required this.count, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Text('$count', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView(scrollDirection: Axis.horizontal, children: children),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _JournalShimmer extends StatelessWidget {
  const _JournalShimmer();

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: baseColor.withOpacity(0.5),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, sectionIndex) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 120, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 12),
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
                          Container(width: 110, height: 140, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                          const SizedBox(height: 6),
                          Container(width: 90, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
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