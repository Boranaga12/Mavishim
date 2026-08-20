const _notProvided = Object();

class DailyLog {
  final String dateKey; // YYYY-MM-DD
  final String? mood;
  final List<String> symptoms;
  final String? intimacy;
  final String? favPosition;
  final String? dailyEmoji; // Günün tek simge emojisi
  final String? note;

  DailyLog({
    required this.dateKey,
    this.mood,
    List<String> symptoms = const [],
    this.intimacy,
    this.favPosition,
    this.dailyEmoji,
    this.note,
  }) : symptoms = List.unmodifiable(symptoms);

  DailyLog copyWith({
    Object? mood = _notProvided,
    Object? symptoms = _notProvided,
    Object? intimacy = _notProvided,
    Object? favPosition = _notProvided,
    Object? dailyEmoji = _notProvided,
    Object? note = _notProvided,
  }) {
    return DailyLog(
      dateKey: dateKey,
      mood: identical(mood, _notProvided) ? this.mood : mood as String?,
      symptoms: identical(symptoms, _notProvided)
          ? this.symptoms
          : List<String>.from(symptoms as List<String>),
      intimacy: identical(intimacy, _notProvided)
          ? this.intimacy
          : intimacy as String?,
      favPosition: identical(favPosition, _notProvided)
          ? this.favPosition
          : favPosition as String?,
      dailyEmoji: identical(dailyEmoji, _notProvided)
          ? this.dailyEmoji
          : dailyEmoji as String?,
      note: identical(note, _notProvided) ? this.note : note as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateKey': dateKey,
      'mood': mood,
      'symptoms': symptoms,
      'intimacy': intimacy,
      'favPosition': favPosition,
      'dailyEmoji': dailyEmoji,
      'note': note,
    };
  }

  factory DailyLog.fromMap(Map<String, dynamic> map) {
    final rawSymptoms = map['symptoms'];
    return DailyLog(
      dateKey: map['dateKey'] is String ? map['dateKey'] as String : '',
      mood: map['mood'] is String ? map['mood'] as String : null,
      symptoms: rawSymptoms is List
          ? rawSymptoms.whereType<String>().toList()
          : const [],
      intimacy: map['intimacy'] is String ? map['intimacy'] as String : null,
      favPosition: map['favPosition'] is String
          ? map['favPosition'] as String
          : null,
      dailyEmoji: map['dailyEmoji'] is String
          ? map['dailyEmoji'] as String
          : null,
      note: map['note'] is String ? map['note'] as String : null,
    );
  }

  bool get isEmpty =>
      mood == null &&
      symptoms.isEmpty &&
      intimacy == null &&
      favPosition == null &&
      dailyEmoji == null &&
      note == null;
}
