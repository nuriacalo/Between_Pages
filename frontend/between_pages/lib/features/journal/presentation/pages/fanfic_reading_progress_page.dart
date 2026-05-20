import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/catalog/presentation/pages/fanfic_edit_page.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/domain/responses/fanfic_journal_response_dto.dart';
import 'package:between_pages/features/journal/presentation/pages/journal_item_edit_page.dart';
import 'package:between_pages/features/notes/presentation/widget/second_brain_tab.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FanficReadingProgressPage extends ConsumerStatefulWidget {
  final FanficJournalResponseDTO journal;

  const FanficReadingProgressPage({super.key, required this.journal});

  @override
  ConsumerState<FanficReadingProgressPage> createState() => _FanficReadingProgressPageState();
}

class _FanficReadingProgressPageState extends ConsumerState<FanficReadingProgressPage> {
  
  FanficJournalResponseDTO get _journal => widget.journal;
  FanfictionResponseDTO get _fanfic => _journal.fanfic;

  void _goToEditFanficDetails() async {
    final result = await Navigator.push<FanfictionResponseDTO>(
      context,
      MaterialPageRoute(
        builder: (_) => FanficEditPage(fanfic: _fanfic),
      ),
    );

    if (result != null && mounted) {
      ref.invalidate(journalEntryProvider((JournalType.fanfic, _fanfic.idFanfic ?? 0)));
      ref.invalidate(journalProvider(JournalType.fanfic));
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Colors.blue[300]!;
    final updatedJournal = ref.watch(journalEntryProvider((JournalType.fanfic, _fanfic.idFanfic ?? 0)));
    final journal = (updatedJournal as FanficJournalResponseDTO?) ?? _journal;
    final fanfic = journal.fanfic;

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
                  fanfic.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                background: _buildHeader(accent, fanfic.coverUrl),
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
              SecondBrainTab(itemType: 'FANFIC', itemId: fanfic.idFanfic ?? 0),
              JournalItemEditPage(journal: journal, type: JournalType.fanfic, isStandalone: false),
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