import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:between_pages/features/auth/application/repositories/auth_repository.dart';
import 'package:between_pages/features/journal/domain/fanfic_journal_record_dto.dart';
import 'package:between_pages/features/journal/domain/fanfic_journal_response_dto.dart';
import 'package:between_pages/features/catalog/presentation/pages/fanfic_edit_page.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/presentation/pages/journal_item_edit_page.dart';
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
      ref.invalidate(journalEntryProvider((JournalType.fanfic, _fanfic.idFanfic)));
      ref.invalidate(journalProvider(JournalType.fanfic));
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Colors.blue[300]!;
    final updatedJournal = ref.watch(journalEntryProvider((JournalType.fanfic, _fanfic.idFanfic)));
    final journal = (updatedJournal as FanficJournalResponseDTO?) ?? _journal;
    final fanfic = journal.fanfic;

    final currentPage = journal.currentChapter ?? 0;
    final totalPages = fanfic.totalChapters;
    final progress = ((totalPages ?? 0) > 0) ? (currentPage / totalPages!).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerScrolled) => [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: accent,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_document),
                tooltip: 'Editar datos del fanfic',
                onPressed: _goToEditFanficDetails,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                fanfic.title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: _buildHeader(accent, fanfic.coverUrl),
            ),
          ),
        ],
        body: JournalItemEditPage(journal: journal, type: JournalType.fanfic),
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
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
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
                          placeholder: (context, url) => Container(color: Colors.white.withOpacity(0.1)),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.white.withOpacity(0.1),
                            child: const Icon(Icons.book, color: Colors.white54, size: 40),
                          ),
                        )
                      : Container(
                          color: Colors.white.withOpacity(0.1),
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