import 'package:flutter/material.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tu reflexión ha sido guardada en el Diario')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
                'Mi Diario',
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
                _buildCelebrationCard(colorScheme, textTheme, data),
                const SizedBox(height: 32),

                // Introducción
                Text(
                  'Tu experiencia de lectura',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Toma un momento para reflexionar sobre esta historia.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Estadísticas
                _buildStatsCard(colorScheme, textTheme, data),
                const SizedBox(height: 32),

                // Reflexión
                _buildSectionTitle('¿Qué te ha dejado esta historia?', textTheme),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(text: _reflection),
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Escribe tus pensamientos, emociones...',
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
                _buildSectionTitle('Cita o escena favorita', textTheme),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(text: _favoriteQuote),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: '¿Hubo algún momento memorable?',
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
                _buildSectionTitle('¿Lo releerías?', textTheme),
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
                    Text('Nunca', style: textTheme.bodySmall),
                    Text(
                      _getRereadLabel(_rereadLikelihood),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: data.accentColor,
                      ),
                    ),
                    Text('Seguro', style: textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 40),

                // Botón guardar
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saveDiary,
                    icon: const Icon(Icons.check),
                    label: const Text('Guardar en mi Diario'),
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
            '¡Has terminado!',
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
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de lectura',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(
                  icon: Icons.star,
                  value: '${data.rating ?? '-'}',
                  label: 'Valoración',
                  color: Colors.amber,
                ),
                _buildStat(
                  icon: Icons.water_drop,
                  value: '${data.tearDrops ?? 0}',
                  label: 'Lágrimas',
                  color: Colors.blue,
                ),
                _buildStat(
                  icon: Icons.local_fire_department,
                  value: '${data.spiceFlames ?? 0}',
                  label: 'Spice',
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

  String _getRereadLabel(int value) {
    return switch (value) {
      <= 3 => 'Poco probable',
      <= 6 => 'Quizás',
      <= 8 => 'Probablemente',
      _ => 'Definitivamente',
    };
  }
}
