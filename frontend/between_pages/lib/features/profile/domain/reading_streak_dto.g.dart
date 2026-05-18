// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_streak_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingStreakDTO _$ReadingStreakDTOFromJson(Map<String, dynamic> json) =>
    ReadingStreakDTO(
      currentStreak:
          (ReadingStreakDTO._readCurrentStreak(json, 'current_streak') as num)
              .toInt(),
      weekActivity:
          (ReadingStreakDTO._readWeekActivity(json, 'week_activity')
                  as List<dynamic>)
              .map((e) => e as bool)
              .toList(),
      totalActiveDays:
          (ReadingStreakDTO._readTotalActiveDays(json, 'total_active_days')
                  as num)
              .toInt(),
    );

Map<String, dynamic> _$ReadingStreakDTOToJson(ReadingStreakDTO instance) =>
    <String, dynamic>{
      'current_streak': instance.currentStreak,
      'week_activity': instance.weekActivity,
      'total_active_days': instance.totalActiveDays,
    };
