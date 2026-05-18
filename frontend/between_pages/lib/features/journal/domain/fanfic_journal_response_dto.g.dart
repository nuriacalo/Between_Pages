// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fanfic_journal_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FanficJournalResponseDTO _$FanficJournalResponseDTOFromJson(
  Map<String, dynamic> json,
) => FanficJournalResponseDTO(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  fanfic: FanfictionResponseDTO.fromJson(
    json['fanfic'] as Map<String, dynamic>,
  ),
  status: json['status'] as String,
  currentChapter: (json['currentChapter'] as num?)?.toInt(),
  rating: (json['rating'] as num?)?.toInt(),
  tearDrops: (json['tearDrops'] as num?)?.toInt(),
  spiceFlames: (json['spiceFlames'] as num?)?.toInt(),
  mainShip: json['mainShip'] as String?,
  secondaryShips: json['secondaryShips'] as String?,
  theme: json['theme'] as String?,
  angstLevel: json['angstLevel'] as String?,
  shipLoyalty: json['shipLoyalty'] as String?,
  canonType: json['canonType'] as String?,
  rereading: json['rereading'] as bool?,
  personalNotes: json['personalNotes'] as String?,
  startDate: json['startDate'] as String?,
  endDate: json['endDate'] as String?,
);

Map<String, dynamic> _$FanficJournalResponseDTOToJson(
  FanficJournalResponseDTO instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'status': instance.status,
  'personalNotes': instance.personalNotes,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
  'rating': instance.rating,
  'tearDrops': instance.tearDrops,
  'spiceFlames': instance.spiceFlames,
  'rereading': instance.rereading,
  'fanfic': instance.fanfic.toJson(),
  'currentChapter': instance.currentChapter,
  'mainShip': instance.mainShip,
  'secondaryShips': instance.secondaryShips,
  'theme': instance.theme,
  'angstLevel': instance.angstLevel,
  'shipLoyalty': instance.shipLoyalty,
  'canonType': instance.canonType,
};
