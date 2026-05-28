import 'package:flutter/material.dart';
import 'package:between_pages/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// Datos comunes extraídos de cualquier tipo de journal para la página del Diario.
class DiaryJournalData {
  final String title;
  final String? author;
  final String? coverUrl;
  final int? rating;
  final int? tearDrops;
  final int? spiceFlames;
  final int? currentProgress; // página o capítulo
  final String? personalNotes;
  final String progressLabel; // "Páginas leídas" o "Capítulos leídos"
  final IconData icon; // icono específico del tipo
  final Color accentColor;

  DiaryJournalData({
    required this.title,
    this.author,
    this.coverUrl,
    this.rating,
    this.tearDrops,
    this.spiceFlames,
    this.currentProgress,
    this.personalNotes,
    required this.progressLabel,
    required this.icon,
    required this.accentColor,
  });
}

/// Página inmersiva del Diario genérica que funciona para Libros, Mangas y Fanfics.
/// Elimina la duplicación de código entre book_diary_page, manga_diary_page y fanfic_diary_page.
class DiaryPage extends StatefulWidget {
  final DiaryJournalData data;

  const DiaryPage({super.key, required this.data});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  late String _reflection;
  late String _favoriteQuote;
  late int _rereadLikelihood;

  @override
  void initState() {
    super.initState();
    _reflection = widget.data.personalNotes ?? '';
    _favoriteQuote = '';
    _rereadLikelihood = 5;
  }

  void _saveDiary() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.diarySaved)),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final data = widget.data;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: colorScheme.surfaceContainerHighest,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                l10n.myDiary,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      data.accentColor.withValues(alpha: 0.3),
                      colorScheme.surfaceContainerHighest,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    data.icon,
                    size: 80,
                    color: data.accentColor.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header de celebración
              _buildCelebrationCard(colorScheme, textTheme, data, l10n),
                const SizedBox(height: 32),

                // Introducción
                Text(
                l10n.readingExperience,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                l10n.reflectionPrompt,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Estadísticas
              _buildStatsCard(colorScheme, textTheme, data, l10n),
                const SizedBox(height: 32),

                // Reflexión
              _buildSectionTitle(l10n.reflectionQuestion, textTheme),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(text: _reflection),
                  maxLines: 5,
                  decoration: InputDecoration(
                  hintText: l10n.reflectionHint,
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) => _reflection = v,
                ),
                const SizedBox(height: 24),

                // Cita favorita
              _buildSectionTitle(l10n.favoriteQuoteTitle, textTheme),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(text: _favoriteQuote),
                  maxLines: 3,
                  decoration: InputDecoration(
                  hintText: l10n.favoriteQuoteHint,
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.format_quote),
                  ),
                  onChanged: (v) => _favoriteQuote = v,
                ),
                const SizedBox(height: 24),

                // Releer
              _buildSectionTitle(l10n.rereadQuestion, textTheme),
                const SizedBox(height: 12),
                Slider(
                  value: _rereadLikelihood.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: _rereadLikelihood.toString(),
                  onChanged: (v) => setState(() => _rereadLikelihood = v.round()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text(l10n.rereadNever, style: textTheme.bodySmall),
                    Text(
                    _getRereadLabel(_rereadLikelihood, l10n),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: data.accentColor,
                      ),
                    ),
                  Text(l10n.rereadSure, style: textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 40),

                // Botón guardar
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saveDiary,
                    icon: const Icon(Icons.check),
                  label: Text(l10n.saveInDiary),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrationCard(
    ColorScheme colorScheme,
    TextTheme textTheme,
    DiaryJournalData data,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: data.accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events, size: 48, color: data.accentColor),
          const SizedBox(height: 12),
          Text(
            l10n.youFinished,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"${data.title}"',
            style: textTheme.titleMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    ColorScheme colorScheme,
    TextTheme textTheme,
    DiaryJournalData data,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
            l10n.readingSummary,
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(
                  icon: Icons.star,
                  value: '${data.rating ?? '-'}',
                label: l10n.rating,
                  color: Colors.amber,
                ),
                _buildStat(
                  icon: Icons.water_drop,
                  value: '${data.tearDrops ?? 0}',
                label: l10n.tears,
                  color: Colors.blue,
                ),
                _buildStat(
                  icon: Icons.local_fire_department,
                  value: '${data.spiceFlames ?? 0}',
                label: l10n.spice,
                  color: Colors.red,
                ),
              ],
            ),
            if (data.currentProgress != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '${data.progressLabel}: ${data.currentProgress}',
                  style: textTheme.bodyMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSectionTitle(String text, TextTheme textTheme) {
    return Text(
      text,
      style: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _getRereadLabel(int value, AppLocalizations l10n) {
    return switch (value) {
      <= 3 => l10n.rereadUnlikely,
      <= 6 => l10n.rereadMaybe,
      <= 8 => l10n.rereadProbably,
      _ => l10n.rereadDefinitely,
    };
  }
}
