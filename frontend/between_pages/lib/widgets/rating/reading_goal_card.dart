import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Tarjeta de meta anual de lectura con indicador circular de progreso.
class ReadingGoalCard extends StatelessWidget {
  final int booksRead;
  final int goal;
  final VoidCallback? onEditGoal;

  const ReadingGoalCard({
    super.key,
    required this.booksRead,
    required this.goal,
    this.onEditGoal,
  });

  double get _progress => goal > 0 ? (booksRead / goal).clamp(0.0, 1.0) : 0.0;

  int get _booksLeft => math.max(0, goal - booksRead);

  String get _motivationText {
    if (goal == 0) return 'Establece una meta de lectura';
    if (booksRead == 0) return '¡Empieza con el primero!';
    if (_progress >= 1.0) return '🎉 ¡Meta conseguida!';
    if (_progress >= 0.75) return '¡Casi lo tienes!';
    if (_progress >= 0.5) return '¡Vas por la mitad!';
    if (_progress >= 0.25) return '¡Buen progreso!';
    return '${_booksLeft} libros para tu meta';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark
        ? const Color(0xFF3D2D30)
        : const Color(0xFFFDF5F2);
    final primaryColor = const Color(0xFFA87C80);
    final accentColor = const Color(0xFFD4A0A4);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Indicador circular
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(72, 72),
                  painter: _CircularProgressPainter(
                    progress: _progress,
                    color: primaryColor,
                    backgroundColor: primaryColor.withValues(alpha: 0.15),
                    strokeWidth: 6,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$booksRead',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                            height: 1,
                          ),
                    ),
                    Text(
                      'de $goal',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 9,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.flag_rounded,
                      size: 16,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Meta ${DateTime.now().year}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const Spacer(),
                    if (onEditGoal != null)
                      GestureDetector(
                        onTap: onEditGoal,
                        child: Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _motivationText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                // Barra de progreso lineal
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: primaryColor.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _progress >= 1.0 ? const Color(0xFF7BAE8E) : primaryColor,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(_progress * 100).toInt()}% completado',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  const _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter old) =>
      old.progress != progress || old.color != color;
}

/// Dialog para editar la meta anual de lectura
class EditReadingGoalDialog extends StatefulWidget {
  final int currentGoal;

  const EditReadingGoalDialog({super.key, required this.currentGoal});

  @override
  State<EditReadingGoalDialog> createState() => _EditReadingGoalDialogState();
}

class _EditReadingGoalDialogState extends State<EditReadingGoalDialog> {
  late int _goal;

  @override
  void initState() {
    super.initState();
    _goal = widget.currentGoal == 0 ? 12 : widget.currentGoal;
  }

  @override
  Widget build(BuildContext context) {
    final presets = [5, 10, 12, 15, 20, 24, 30, 40, 50, 52, 75, 100];

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.flag_rounded, color: Color(0xFFA87C80)),
          SizedBox(width: 8),
          Text('Meta de lectura'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Cuántos libros quieres leer en ${DateTime.now().year}?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '$_goal libros',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFA87C80),
                    ),
              ),
            ),
            Slider(
              value: _goal.toDouble(),
              min: 1,
              max: 100,
              divisions: 99,
              activeColor: const Color(0xFFA87C80),
              onChanged: (v) => setState(() => _goal = v.toInt()),
            ),
            const SizedBox(height: 8),
            Text(
              'Accesos rápidos',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presets.map((p) {
                final sel = _goal == p;
                return GestureDetector(
                  onTap: () => setState(() => _goal = p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFFA87C80)
                          : const Color(0xFFA87C80).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFA87C80).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '$p',
                      style: TextStyle(
                        color: sel ? Colors.white : const Color(0xFFA87C80),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_goal),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFA87C80),
          ),
          child: const Text('Guardar meta'),
        ),
      ],
    );
  }
}
