class GamificationStatsDTO {
  final int annualGoal;
  final int currentStreak;
  final List<bool> weekActivity;

  GamificationStatsDTO({
    required this.annualGoal,
    required this.currentStreak,
    required this.weekActivity,
  });

  factory GamificationStatsDTO.fromJson(Map<String, dynamic> json) {
    return GamificationStatsDTO(
      annualGoal: json['annualGoal'] as int? ?? 12,
      currentStreak: json['currentStreak'] as int? ?? 0,
      weekActivity: (json['weekActivity'] as List<dynamic>?)
              ?.map((e) => e as bool)
              .toList() ??
          List.filled(7, false),
    );
  }
}