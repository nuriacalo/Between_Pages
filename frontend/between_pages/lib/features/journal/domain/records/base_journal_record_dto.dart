abstract class BaseJournalRecordDTO {
  int get userId;
  String get status;
  int? get rating;
  int? get tearDrops;
  int? get spiceFlames;
  String? get personalNotes;
  String? get startDate;
  String? get endDate;
  bool? get rereading;
  String? get ownership;

  Map<String, dynamic> toJson();
}
