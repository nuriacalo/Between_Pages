class ReadingStreakDTO {
  final int currentStreak;
  final List<bool> weekActivity; // 7 días, true si hubo actividad ese día
  final int totalActiveDays;

  ReadingStreakDTO({
    required this.currentStreak,
    required this.weekActivity,
    required this.totalActiveDays,
  });

  factory ReadingStreakDTO.fromJson(Map<String, dynamic> json) {
    return ReadingStreakDTO(
      currentStreak: json['current_streak'] as int? ?? json['currentStreak'] as int? ?? 0,
      weekActivity: (json['week_activity'] as List<dynamic>?)
              ?.map((e) => e as bool)
              .toList() ??
          (json['weekActivity'] as List<dynamic>?)
              ?.map((e) => e as bool)
              .toList() ??
          List.generate(7, (_) => false),
      totalActiveDays: json['total_active_days'] as int? ?? json['totalActiveDays'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_streak': currentStreak,
      'week_activity': weekActivity,
      'total_active_days': totalActiveDays,
    };
  }

  /// Obtiene el índice del día actual (0 = Lunes, 6 = Domingo)
  int get todayIndex {
    final now = DateTime.now();
    // weekday: 1 = Lunes, 7 = Domingo
    return now.weekday - 1;
  }

  /// Verifica si hay actividad hoy
  bool get hasActivityToday {
    if (todayIndex < 0 || todayIndex >= weekActivity.length) return false;
    return weekActivity[todayIndex];
  }
}
