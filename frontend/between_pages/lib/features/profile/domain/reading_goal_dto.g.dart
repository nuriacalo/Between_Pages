// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_goal_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingGoalDTO _$ReadingGoalDTOFromJson(
  Map<String, dynamic> json,
) => ReadingGoalDTO(
  id: (json['id'] as num).toInt(),
  goalYear: (ReadingGoalDTO._readGoalYear(json, 'goal_year') as num).toInt(),
  targetAmount: (ReadingGoalDTO._readTargetAmount(json, 'target_amount') as num)
      .toInt(),
);

Map<String, dynamic> _$ReadingGoalDTOToJson(ReadingGoalDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goal_year': instance.goalYear,
      'target_amount': instance.targetAmount,
    };
