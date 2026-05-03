class ReadingGoalDTO {
  final int id;
  final int goalYear;
  final int targetAmount;

  ReadingGoalDTO({
    required this.id,
    required this.goalYear,
    required this.targetAmount,
  });

  factory ReadingGoalDTO.fromJson(Map<String, dynamic> json) {
    return ReadingGoalDTO(
      id: json['id'] as int? ?? 0,
      goalYear: json['goal_year'] as int? ?? json['goalYear'] as int? ?? DateTime.now().year,
      targetAmount: json['target_amount'] as int? ?? json['targetAmount'] as int? ?? 12,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal_year': goalYear,
      'target_amount': targetAmount,
    };
  }
}
