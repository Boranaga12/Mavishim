import '../../models/daily_log.dart';
import '../../models/wheel_model.dart';
import '../../models/tap_heart.dart';
import '../quiz_questions.dart';

class AppDataSnapshot {
  final List<DateTime> periodHistory;
  final int cycleLength;
  final int periodDuration;
  final bool isBoyfriendMode;
  final Map<String, DailyLog> dailyLogs;
  final int memoryBestScore;
  final int quizBestScore;
  final int activeWheelIndex;
  final List<WheelModel> wheels;
  final List<QuizQuestion> quizQuestions;
  final List<TapHeart> tapHearts;
  final Map<String, int> gameProgress;

  AppDataSnapshot({
    required List<DateTime> periodHistory,
    required this.cycleLength,
    required this.periodDuration,
    required this.isBoyfriendMode,
    required Map<String, DailyLog> dailyLogs,
    required this.memoryBestScore,
    required this.quizBestScore,
    required this.activeWheelIndex,
    required List<WheelModel> wheels,
    required List<QuizQuestion> quizQuestions,
    required List<TapHeart> tapHearts,
    Map<String, int> gameProgress = const {},
  }) : periodHistory = List.unmodifiable(periodHistory),
       dailyLogs = Map.unmodifiable(dailyLogs),
       wheels = List.unmodifiable(wheels),
       quizQuestions = List.unmodifiable(quizQuestions),
       tapHearts = List.unmodifiable(tapHearts),
       gameProgress = Map.unmodifiable(gameProgress);
}

abstract interface class AppRepository {
  Future<AppDataSnapshot> load();

  Future<void> saveCycleSettings({
    required List<DateTime> periodHistory,
    required int cycleLength,
    required int periodDuration,
    required bool isBoyfriendMode,
  });

  Future<void> saveDailyLog(DailyLog log);

  Future<void> deleteDailyLog(String dateKey);

  Future<void> saveGameState({
    required int memoryBestScore,
    required int quizBestScore,
    required int activeWheelIndex,
    required List<WheelModel> wheels,
    required List<QuizQuestion> quizQuestions,
  });

  Future<void> clearAllData();

  Future<void> saveTapHearts(List<TapHeart> hearts);

  Future<void> saveGameProgress(Map<String, int> progress);
}

class AppStorageException implements Exception {
  final String operation;
  final Object cause;

  const AppStorageException(this.operation, this.cause);

  @override
  String toString() => 'AppStorageException($operation): $cause';
}
