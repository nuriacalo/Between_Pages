import 'package:flutter/material.dart';

/// Tarjeta de racha de lectura con marcadores semanales.
/// [streak] es el número de días consecutivos.
/// [weekActivity] lista de 7 bools (lun→dom) indicando si leyó ese día.
class ReadingStreakCard extends StatelessWidget {
  final int streak;
  final List<bool> weekActivity; // 7 elementos, índice 0 = lunes

  const ReadingStreakCard({
    super.key,
    required this.streak,
    required this.weekActivity,
  });

  static const _days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  String get _streakMessage {
    if (streak == 0) return 'Empieza tu racha hoy 📖';
    if (streak < 3) return '¡Buen comienzo! Sigue así';
    if (streak < 7) return '¡Estás en racha!';
    if (streak < 14) return '¡Una semana seguida! 🔥';
    if (streak < 30) return '¡Lector/a imparable! 🏆';
    return '¡Leyenda de las letras! 👑';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark
        ? const Color(0xFF3D2D30)
        : const Color(0xFFFDF5F2);
    final accentColor = const Color(0xFFE8A87C);
    final todayIndex = DateTime.now().weekday - 1; // 0=lun, 6=dom

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Racha de lectura',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    '$streak ${streak == 1 ? 'día' : 'días'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Marcadores semanales
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final isToday = i == todayIndex;
              final didRead = i < weekActivity.length && weekActivity[i];

              return Column(
                children: [
                  Text(
                    _days[i],
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isToday
                              ? accentColor
                              : colorScheme.onSurfaceVariant,
                          fontWeight: isToday ? FontWeight.bold : null,
                        ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: didRead
                          ? accentColor
                          : isToday
                              ? accentColor.withValues(alpha: 0.15)
                              : colorScheme.surfaceContainerHighest,
                      border: isToday && !didRead
                          ? Border.all(color: accentColor, width: 1.5)
                          : null,
                    ),
                    child: Center(
                      child: didRead
                          ? Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Colors.white,
                            )
                          : isToday
                              ? Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accentColor,
                                  ),
                                )
                              : null,
                    ),
                  ),
                ],
              );
            }),
          ),

          const SizedBox(height: 12),
          Text(
            _streakMessage,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }
}
