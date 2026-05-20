import 'package:between_pages/features/catalog/domain/manga_response_dto.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/catalog/presentation/pages/manga_edit_page.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/domain/responses/manga_journal_response_dto.dart';
import 'package:between_pages/features/journal/presentation/pages/journal_item_edit_page.dart';
import 'package:between_pages/features/notes/presentation/widget/second_brain_tab.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MangaReadingProgressPage extends ConsumerStatefulWidget {
  final MangaJournalResponseDTO journal;

  const MangaReadingProgressPage({super.key, required this.journal});

  @override
  ConsumerState<MangaReadingProgressPage> createState() => _MangaReadingProgressPageState();
}

class _MangaReadingProgressPageState extends ConsumerState<MangaReadingProgressPage> {
  
  MangaJournalResponseDTO get _journal => widget.journal;
  MangaResponseDTO get _manga => _journal.manga!;

  void _goToEditMangaDetails() async {
    final result = await Navigator.push<MangaResponseDTO>(
      context,
      MaterialPageRoute(
        builder: (_) => MangaEditPage(manga: _manga),
      ),
    );

    if (result != null && mounted) {
      ref.invalidate(journalEntryProvider((JournalType.manga, _manga.idManga ?? 0)));
      ref.invalidate(journalProvider(JournalType.manga));
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Colors.green[300]!;
    final updatedJournal = ref.watch(journalEntryProvider((JournalType.manga, _manga.idManga ?? 0)));
    final journal = (updatedJournal as MangaJournalResponseDTO?) ?? _journal;
    final manga = journal.manga!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerScrolled) => [
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              backgroundColor: accent,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  manga.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                background: _buildHeader(accent, manga.coverUrl),
              ),
              bottom: const TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: 'Segundo Cerebro'),
                  Tab(text: 'Editar'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              SecondBrainTab(itemType: 'MANGA', itemId: manga.idManga ?? 0),
              JournalItemEditPage(journal: journal, type: JournalType.manga, isStandalone: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color accent, String? coverUrl) {
    return Container(
      color: accent,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 40, bottom: 60),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(77), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 120,
                  height: 180,
                  child: coverUrl != null && coverUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: coverUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.white.withAlpha(26)),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.white.withAlpha(26),
                            child: const Icon(Icons.book, color: Colors.white54, size: 40),
                          ),
                        )
                      : Container(
                          color: Colors.white.withAlpha(26),
                          child: const Icon(Icons.book, color: Colors.white54, size: 40),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}