// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gamification_stats_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GamificationStatsDTO _$GamificationStatsDTOFromJson(
  Map<String, dynamic> json,
) => GamificationStatsDTO(
  annualGoal: (json['annualGoal'] as num?)?.toInt() ?? 12,
  currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
  weekActivity:
      (json['weekActivity'] as List<dynamic>?)
          ?.map((e) => e as bool)
          .toList() ??
      [false, false, false, false, false, false, false],
);

Map<String, dynamic> _$GamificationStatsDTOToJson(
  GamificationStatsDTO instance,
) => <String, dynamic>{
  'annualGoal': instance.annualGoal,
  'currentStreak': instance.currentStreak,
  'weekActivity': instance.weekActivity,
};
