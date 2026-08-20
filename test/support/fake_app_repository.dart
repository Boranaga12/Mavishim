import 'package:mavishim/data/default_wheels.dart';
import 'package:mavishim/data/quiz_questions.dart';
import 'package:mavishim/data/repositories/app_repository.dart';
import 'package:mavishim/models/daily_log.dart';
import 'package:mavishim/models/wheel_model.dart';
import 'package:mavishim/models/tap_heart.dart';

class FakeAppRepository implements AppRepository {
  AppDataSnapshot snapshot;
  bool shouldFail = false;

  FakeAppRepository({AppDataSnapshot? snapshot})
    : snapshot = snapshot ?? emptySnapshot();

  @override
  Future<AppDataSnapshot> load() async => snapshot;

  @override
  Future<void> saveCycleSettings({
    required List<DateTime> periodHistory,
    required int cycleLength,
    required int periodDuration,
    required bool isBoyfriendMode,
  }) async {
    _checkFailure();
    snapshot = _copy(
      periodHistory: periodHistory,
      cycleLength: cycleLength,
      periodDuration: periodDuration,
      isBoyfriendMode: isBoyfriendMode,
    );
  }

  @override
  Future<void> saveDailyLog(DailyLog log) async {
    _checkFailure();
    snapshot = _copy(dailyLogs: {...snapshot.dailyLogs, log.dateKey: log});
  }

  @override
  Future<void> deleteDailyLog(String dateKey) async {
    _checkFailure();
    final logs = Map<String, DailyLog>.from(snapshot.dailyLogs)
      ..remove(dateKey);
    snapshot = _copy(dailyLogs: logs);
  }

  @override
  Future<void> saveGameState({
    required int memoryBestScore,
    required int quizBestScore,
    required int activeWheelIndex,
    required List<WheelModel> wheels,
    required List<QuizQuestion> quizQuestions,
  }) async {
    _checkFailure();
    snapshot = _copy(
      memoryBestScore: memoryBestScore,
      quizBestScore: quizBestScore,
      activeWheelIndex: activeWheelIndex,
      wheels: wheels,
      quizQuestions: quizQuestions,
    );
  }

  @override
  Future<void> clearAllData() async {
    _checkFailure();
    snapshot = emptySnapshot();
  }

  @override
  Future<void> saveTapHearts(List<TapHeart> hearts) async {
    _checkFailure();
    snapshot = _copy(tapHearts: hearts);
  }

  void _checkFailure() {
    if (shouldFail) {
      throw const AppStorageException('fake operation', 'forced failure');
    }
  }

  AppDataSnapshot _copy({
    List<DateTime>? periodHistory,
    int? cycleLength,
    int? periodDuration,
    bool? isBoyfriendMode,
    Map<String, DailyLog>? dailyLogs,
    int? memoryBestScore,
    int? quizBestScore,
    int? activeWheelIndex,
    List<WheelModel>? wheels,
    List<QuizQuestion>? quizQuestions,
    List<TapHeart>? tapHearts,
  }) => AppDataSnapshot(
    periodHistory: periodHistory ?? snapshot.periodHistory,
    cycleLength: cycleLength ?? snapshot.cycleLength,
    periodDuration: periodDuration ?? snapshot.periodDuration,
    isBoyfriendMode: isBoyfriendMode ?? snapshot.isBoyfriendMode,
    dailyLogs: dailyLogs ?? snapshot.dailyLogs,
    memoryBestScore: memoryBestScore ?? snapshot.memoryBestScore,
    quizBestScore: quizBestScore ?? snapshot.quizBestScore,
    activeWheelIndex: activeWheelIndex ?? snapshot.activeWheelIndex,
    wheels: wheels ?? snapshot.wheels,
    quizQuestions: quizQuestions ?? snapshot.quizQuestions,
    tapHearts: tapHearts ?? snapshot.tapHearts,
  );
}

AppDataSnapshot emptySnapshot() => AppDataSnapshot(
  periodHistory: const [],
  cycleLength: 28,
  periodDuration: 5,
  isBoyfriendMode: false,
  dailyLogs: const {},
  memoryBestScore: 0,
  quizBestScore: 0,
  activeWheelIndex: 0,
  wheels: List.of(defaultWheels),
  quizQuestions: List.of(customQuizQuestions),
  tapHearts: const [],
);
