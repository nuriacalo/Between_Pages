import 'package:json_annotation/json_annotation.dart';

part 'reading_streak_dto.g.dart';

@JsonSerializable()
class ReadingStreakDTO {
  @JsonKey(name: 'current_streak', readValue: _readCurrentStreak)
  final int currentStreak;
  
  @JsonKey(name: 'week_activity', readValue: _readWeekActivity)
  final List<bool> weekActivity;
  
  @JsonKey(name: 'total_active_days', readValue: _readTotalActiveDays)
  final int totalActiveDays;

  ReadingStreakDTO({
    required this.currentStreak,
    required this.weekActivity,
    required this.totalActiveDays,
  });

  static Object? _readCurrentStreak(Map<dynamic, dynamic> json, String key) {
    return json['current_streak'] ?? json['currentStreak'] ?? 0;
  }

  static Object? _readWeekActivity(Map<dynamic, dynamic> json, String key) {
    return json['week_activity'] ?? json['weekActivity'] ?? List.filled(7, false);
  }

  static Object? _readTotalActiveDays(Map<dynamic, dynamic> json, String key) {
    return json['total_active_days'] ?? json['totalActiveDays'] ?? 0;
  }

  factory ReadingStreakDTO.fromJson(Map<String, dynamic> json) => 
      _$ReadingStreakDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingStreakDTOToJson(this);

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
