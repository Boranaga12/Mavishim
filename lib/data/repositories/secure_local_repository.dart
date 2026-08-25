import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/daily_log.dart';
import '../../models/wheel_model.dart';
import '../../models/tap_heart.dart';
import '../quiz_questions.dart';
import '../default_wheels.dart';
import 'app_repository.dart';

class SecureLocalRepository implements AppRepository {
  static const _keyName = 'mavishim_hive_key_v1';
  static const _settingsBoxName = 'mavishim_settings_v2';
  static const _logsBoxName = 'mavishim_daily_logs_v2';
  static const _wheelsBoxName = 'mavishim_wheels_v2';

  final Box<dynamic> _settings;
  final Box<dynamic> _logs;
  final Box<dynamic> _wheels;

  SecureLocalRepository._(this._settings, this._logs, this._wheels);

  static Future<SecureLocalRepository> create({
    FlutterSecureStorage secureStorage = const FlutterSecureStorage(),
  }) async {
    try {
      await Hive.initFlutter();
      var encodedKey = await secureStorage.read(key: _keyName);
      if (encodedKey == null) {
        encodedKey = base64UrlEncode(Hive.generateSecureKey());
        await secureStorage.write(key: _keyName, value: encodedKey);
      }

      final cipher = HiveAesCipher(base64Url.decode(encodedKey));
      final boxes = await Future.wait<Box<dynamic>>([
        Hive.openBox<dynamic>(_settingsBoxName, encryptionCipher: cipher),
        Hive.openBox<dynamic>(_logsBoxName, encryptionCipher: cipher),
        Hive.openBox<dynamic>(_wheelsBoxName, encryptionCipher: cipher),
      ]);
      final repository = SecureLocalRepository._(boxes[0], boxes[1], boxes[2]);
      await repository._migrateLegacyPreferences();
      return repository;
    } catch (error) {
      throw AppStorageException('secure database initialization', error);
    }
  }

  @override
  Future<AppDataSnapshot> load() async {
    try {
      final periodHistory =
          (_settings.get('periodHistory') as List? ?? const [])
              .whereType<String>()
              .map(DateTime.tryParse)
              .whereType<DateTime>()
              .map(_dateOnly)
              .toList()
            ..sort((a, b) => b.compareTo(a));

      final dailyLogs = <String, DailyLog>{};
      for (final entry in _logs.toMap().entries) {
        final value = _stringKeyMap(entry.value);
        if (value != null) {
          dailyLogs[entry.key.toString()] = DailyLog.fromMap(value);
        }
      }

      final storedWheels = <WheelModel>[];
      for (final entry in _wheels.toMap().entries) {
        final value = _stringKeyMap(entry.value);
        if (value != null) {
          final wheel = WheelModel.fromMap(value);
          if (wheel.id.isNotEmpty && wheel.options.length >= 2) {
            storedWheels.add(refreshBuiltInWheelOptions(wheel));
          }
        }
      }
      final wheels = storedWheels.isEmpty ? defaultWheels : storedWheels;
      final activeIndex = (_settings.get('activeWheelIndex') as int? ?? 0)
          .clamp(0, wheels.length - 1)
          .toInt();
      final tapHearts = (_settings.get('tapHearts') as List? ?? const [])
          .map(_stringKeyMap)
          .whereType<Map<String, dynamic>>()
          .map(TapHeart.fromMap)
          .where((heart) => heart.id.isNotEmpty)
          .toList();
      final gameProgress = <String, int>{};
      final storedProgress = _settings.get('gameProgress');
      if (storedProgress is Map) {
        for (final entry in storedProgress.entries) {
          if (entry.value is num) {
            gameProgress[entry.key.toString()] = (entry.value as num).toInt();
          }
        }
      }

      return AppDataSnapshot(
        periodHistory: periodHistory,
        cycleLength: (_settings.get('cycleLength') as int? ?? 28)
            .clamp(15, 60)
            .toInt(),
        periodDuration: (_settings.get('periodDuration') as int? ?? 5)
            .clamp(1, 10)
            .toInt(),
        isBoyfriendMode: _settings.get('isBoyfriendMode') as bool? ?? false,
        dailyLogs: dailyLogs,
        memoryBestScore: _settings.get('memoryBestScore') as int? ?? 0,
        quizBestScore: (_settings.get('quizBestScore') as int? ?? 0)
            .clamp(0, 100)
            .toInt(),
        activeWheelIndex: activeIndex,
        wheels: wheels,
        // Quiz content is source-controlled; saved edits cannot override it.
        quizQuestions: customQuizQuestions,
        tapHearts: tapHearts,
        gameProgress: gameProgress,
      );
    } catch (error) {
      throw AppStorageException('load', error);
    }
  }

  @override
  Future<void> saveCycleSettings({
    required List<DateTime> periodHistory,
    required int cycleLength,
    required int periodDuration,
    required bool isBoyfriendMode,
  }) async {
    try {
      await _settings.putAll({
        'periodHistory': periodHistory
            .map((date) => _dateOnly(date).toIso8601String())
            .toList(),
        'cycleLength': cycleLength,
        'periodDuration': periodDuration,
        'isBoyfriendMode': isBoyfriendMode,
      });
    } catch (error) {
      throw AppStorageException('save cycle settings', error);
    }
  }

  @override
  Future<void> saveDailyLog(DailyLog log) async {
    try {
      await _logs.put(log.dateKey, log.toMap());
    } catch (error) {
      throw AppStorageException('save daily log', error);
    }
  }

  @override
  Future<void> deleteDailyLog(String dateKey) async {
    try {
      await _logs.delete(dateKey);
    } catch (error) {
      throw AppStorageException('delete daily log', error);
    }
  }

  @override
  Future<void> saveGameState({
    required int memoryBestScore,
    required int quizBestScore,
    required int activeWheelIndex,
    required List<WheelModel> wheels,
    required List<QuizQuestion> quizQuestions,
  }) async {
    try {
      await _settings.putAll({
        'memoryBestScore': memoryBestScore,
        'quizBestScore': quizBestScore.clamp(0, 100),
        'activeWheelIndex': activeWheelIndex,
        'quizQuestions': quizQuestions.map((item) => item.toMap()).toList(),
      });
      final serializedWheels = {
        for (final wheel in wheels) wheel.id: wheel.toMap(),
      };
      await _wheels.putAll(serializedWheels);
      final staleKeys = _wheels.keys
          .where((key) => !serializedWheels.containsKey(key))
          .toList();
      if (staleKeys.isNotEmpty) await _wheels.deleteAll(staleKeys);
    } catch (error) {
      throw AppStorageException('save game state', error);
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      await Future.wait([_settings.clear(), _logs.clear(), _wheels.clear()]);
      final preferences = await SharedPreferences.getInstance();
      await Future.wait(_legacyKeys.map(preferences.remove));
    } catch (error) {
      throw AppStorageException('delete all data', error);
    }
  }

  @override
  Future<void> saveTapHearts(List<TapHeart> hearts) async {
    try {
      await _settings.put(
        'tapHearts',
        hearts.map((heart) => heart.toMap()).toList(),
      );
    } catch (error) {
      throw AppStorageException('save tap hearts', error);
    }
  }

  @override
  Future<void> saveGameProgress(Map<String, int> progress) async {
    try {
      await _settings.put('gameProgress', Map<String, int>.from(progress));
    } catch (error) {
      throw AppStorageException('save game progress', error);
    }
  }

  Future<void> _migrateLegacyPreferences() async {
    if (_settings.get('legacyMigrationComplete') == true) return;
    final preferences = await SharedPreferences.getInstance();

    final rawLogs = preferences.getString('daily_logs');
    if (_logs.isEmpty && rawLogs != null) {
      try {
        final decoded = json.decode(rawLogs);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            final map = _stringKeyMap(entry.value);
            if (map != null) await _logs.put(entry.key.toString(), map);
          }
        }
      } on FormatException {
        // A malformed legacy JSON blob is skipped so the encrypted database remains usable.
      }
    }

    await _settings.putAll({
      if (!_settings.containsKey('periodHistory'))
        'periodHistory':
            preferences.getStringList('period_history_dates') ??
            const <String>[],
      if (!_settings.containsKey('cycleLength'))
        'cycleLength': preferences.getInt('cycle_length') ?? 28,
      if (!_settings.containsKey('periodDuration'))
        'periodDuration': preferences.getInt('period_duration') ?? 5,
      if (!_settings.containsKey('isBoyfriendMode'))
        'isBoyfriendMode': preferences.getBool('boyfriend_mode') ?? false,
      if (!_settings.containsKey('memoryBestScore'))
        'memoryBestScore': preferences.getInt('memory_best_score') ?? 0,
      if (!_settings.containsKey('quizBestScore'))
        'quizBestScore': (preferences.getInt('quiz_best_score') ?? 0).clamp(
          0,
          100,
        ),
      'legacyMigrationComplete': true,
    });

    await Future.wait(_legacyKeys.map(preferences.remove));
  }

  static Map<String, dynamic>? _stringKeyMap(Object? value) {
    if (value is! Map) return null;
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static const _legacyKeys = [
    'period_history_dates',
    'last_period_date',
    'cycle_length',
    'period_duration',
    'boyfriend_mode',
    'daily_logs',
    'memory_best_score',
    'quiz_best_score',
  ];
}
