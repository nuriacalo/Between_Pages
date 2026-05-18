import 'package:json_annotation/json_annotation.dart';

part 'gamification_stats_dto.g.dart';

@JsonSerializable()
class GamificationStatsDTO {
  @JsonKey(defaultValue: 12)
  final int annualGoal;
  
  @JsonKey(defaultValue: 0)
  final int currentStreak;
  
  @JsonKey(defaultValue: [false, false, false, false, false, false, false])
  final List<bool> weekActivity;

  GamificationStatsDTO({
    required this.annualGoal,
    required this.currentStreak,
    required this.weekActivity,
  });

  factory GamificationStatsDTO.fromJson(Map<String, dynamic> json) => 
      _$GamificationStatsDTOFromJson(json);

  Map<String, dynamic> toJson() => _$GamificationStatsDTOToJson(this);
}
