// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fanfic_journal_record_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FanficJournalRecordDTO _$FanficJournalRecordDTOFromJson(
  Map<String, dynamic> json,
) => FanficJournalRecordDTO(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['userId'] as num).toInt(),
  fanficId: (FanficJournalRecordDTO._readFanficId(json, 'fanficId') as num)
      .toInt(),
  ao3Id: json['ao3Id'] as String?,
  status: json['status'] as String,
  currentChapter: (json['currentChapter'] as num?)?.toInt(),
  rating: (json['rating'] as num?)?.toInt(),
  tearDrops: (json['tearDrops'] as num?)?.toInt(),
  spiceFlames: (json['spiceFlames'] as num?)?.toInt(),
  mainShip: json['mainShip'] as String?,
  secondaryShips: json['secondaryShips'] as String?,
  angstLevel: json['angstLevel'] as String?,
  shipLoyalty: json['shipLoyalty'] as String?,
  canonType: json['canonType'] as String?,
  rereading: json['rereading'] as bool?,
  personalNotes: json['personalNotes'] as String?,
  startDate: json['startDate'] as String?,
  endDate: json['endDate'] as String?,
  ownership: json['ownership'] as String?,
  readingFormat: json['readingFormat'] as String?,
  loanedTo: json['loanedTo'] as String?,
);

Map<String, dynamic> _$FanficJournalRecordDTOToJson(
  FanficJournalRecordDTO instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'userId': instance.userId,
  'fanficId': instance.fanficId,
  'ao3Id': ?instance.ao3Id,
  'status': instance.status,
  'currentChapter': ?instance.currentChapter,
  'rating': ?instance.rating,
  'tearDrops': ?instance.tearDrops,
  'spiceFlames': ?instance.spiceFlames,
  'mainShip': ?instance.mainShip,
  'secondaryShips': ?instance.secondaryShips,
  'angstLevel': ?instance.angstLevel,
  'shipLoyalty': ?instance.shipLoyalty,
  'canonType': ?instance.canonType,
  'rereading': ?instance.rereading,
  'personalNotes': ?instance.personalNotes,
  'startDate': ?instance.startDate,
  'endDate': ?instance.endDate,
  'ownership': ?instance.ownership,
  'readingFormat': ?instance.readingFormat,
  'loanedTo': ?instance.loanedTo,
};
