import 'package:json_annotation/json_annotation.dart';

part 'reading_goal_dto.g.dart';

@JsonSerializable()
class ReadingGoalDTO {
  final int id;
  
  @JsonKey(name: 'goal_year', readValue: _readGoalYear)
  final int goalYear;
  
  @JsonKey(name: 'target_amount', readValue: _readTargetAmount)
  final int targetAmount;

  ReadingGoalDTO({
    required this.id,
    required this.goalYear,
    required this.targetAmount,
  });

  static Object? _readGoalYear(Map<dynamic, dynamic> json, String key) {
    return json['goal_year'] ?? json['goalYear'] ?? DateTime.now().year;
  }

  static Object? _readTargetAmount(Map<dynamic, dynamic> json, String key) {
    return json['target_amount'] ?? json['targetAmount'] ?? 12;
  }

  factory ReadingGoalDTO.fromJson(Map<String, dynamic> json) => 
      _$ReadingGoalDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingGoalDTOToJson(this);
}
