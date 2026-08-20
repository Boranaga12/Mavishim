import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../core/utils/cycle_calculator.dart';
import '../data/repositories/app_repository.dart';
import '../models/daily_log.dart';

typedef NowProvider = DateTime Function();

class CycleProvider with ChangeNotifier {
  final AppRepository _repository;
  final NowProvider _now;

  late List<DateTime> _periodHistory;
  late int _cycleLength;
  late int _periodDuration;
  late Map<String, DailyLog> _dailyLogs;
  String? _errorMessage;
  bool _isSaving = false;

  CycleProvider(this._repository, AppDataSnapshot snapshot, {NowProvider? now})
    : _now = now ?? DateTime.now {
    _applySnapshot(snapshot);
  }

  UnmodifiableListView<DateTime> get periodHistory =>
      UnmodifiableListView(_periodHistory);
  int get cycleLength => _cycleLength;
  int get periodDuration => _periodDuration;
  UnmodifiableMapView<String, DailyLog> get dailyLogs =>
      UnmodifiableMapView(_dailyLogs);
  String? get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;

  DateTime? get lastPeriodDate =>
      _periodHistory.isEmpty ? null : _periodHistory.first;

  CyclePattern get cyclePattern =>
      CyclePattern.fromHistory(_periodHistory, fallbackLength: _cycleLength);

  List<String> get professionalInsights {
    final insights = [...cyclePattern.insights];
    final moodLogs = _dailyLogs.values
        .where((log) => log.mood != null)
        .toList();
    if (moodLogs.length >= 6 && cyclePattern.rhythm == CycleRhythm.regular) {
      insights.add(
        'Ruh modu kayıtların düzenli döngü ritmiyle birlikte ilerliyor; bu düzenli kayıtlar tahmin penceresinin güvenini artırır.',
      );
    } else if (moodLogs.length >= 4 &&
        cyclePattern.rhythm == CycleRhythm.variable) {
      insights.add(
        'Ruh modu ve döngü kayıtları farklı günlerde yoğunlaşıyor. Düzenli günlük kayıtlar kişisel örüntüyü ayırt etmeye yardımcı olur.',
      );
    } else if (moodLogs.isEmpty) {
      insights.add(
        'Mod kaydı eklemek, zaman içindeki kişisel belirtileri ve döngü örüntünü birlikte görmene yardımcı olur.',
      );
    }
    return insights;
  }

  int get estimatedCycleLength {
    if (_periodHistory.length < 2) return _cycleLength;
    final intervals = <int>[];
    for (var index = 0; index < _periodHistory.length - 1; index++) {
      final interval = _periodHistory[index]
          .difference(_periodHistory[index + 1])
          .inDays;
      if (interval >= 15 && interval <= 60) intervals.add(interval);
    }
    if (intervals.isEmpty) return _cycleLength;
    return (intervals.reduce((a, b) => a + b) / intervals.length).round();
  }

  DateTime? get nextExpectedPeriodDate {
    final last = lastPeriodDate;
    return last?.add(Duration(days: estimatedCycleLength));
  }

  DateTime? get nextExpectedOvulationDate =>
      nextExpectedPeriodDate?.subtract(const Duration(days: 14));

  CycleInfo get cycleInfo => infoForDate(_now());

  CycleInfo infoForDate(DateTime date) => CycleInfo(
    lastPeriodDate: lastPeriodDate,
    periodHistory: _periodHistory,
    cycleLength: estimatedCycleLength,
    periodDuration: _periodDuration,
    targetDate: date,
  );

  Future<String?> addPeriodDate(DateTime date) async {
    final normalized = _dateOnly(date);
    final today = _dateOnly(_now());
    if (normalized.isAfter(today)) {
      return 'Gelecek bir tarih için regl kaydı girilemez.';
    }

    for (final existing in _periodHistory) {
      if (normalized.difference(existing).inDays.abs() < 10) {
        return 'Regl başlangıçları arasında en az 10 gün olmalıdır.';
      }
    }

    final previous = List<DateTime>.from(_periodHistory);
    _periodHistory.add(normalized);
    _sortHistory();
    notifyListeners();
    try {
      await _saveCycleSettings();
      return null;
    } catch (_) {
      _periodHistory = previous;
      _setError('Regl kaydı güvenli depolamaya yazılamadı.');
      return _errorMessage;
    }
  }

  Future<bool> removePeriodDate(DateTime date) async {
    final previous = List<DateTime>.from(_periodHistory);
    _periodHistory.removeWhere((item) => isSameDay(item, date));
    notifyListeners();
    try {
      await _saveCycleSettings();
      return true;
    } catch (_) {
      _periodHistory = previous;
      _setError('Regl kaydı silinemedi.');
      return false;
    }
  }

  bool isPeriodStartDate(DateTime date) =>
      _periodHistory.any((item) => isSameDay(item, date));

  bool isRecordedPeriodDay(DateTime date) {
    final normalized = _dateOnly(date);
    return _periodHistory.any((start) {
      final difference = normalized.difference(start).inDays;
      return difference >= 0 && difference < _periodDuration;
    });
  }

  bool isNextPredictedPeriodDay(DateTime date) {
    final expected = nextExpectedPeriodDate;
    if (expected == null) return false;
    final normalized = _dateOnly(date);
    if (normalized.isBefore(_dateOnly(_now()))) return false;
    final difference = normalized.difference(expected).inDays;
    return difference >= 0 && difference < _periodDuration;
  }

  bool isPredictionWindowDay(DateTime date) {
    final info = cycleInfo;
    final normalized = _dateOnly(date);
    if (normalized.isBefore(_dateOnly(_now()))) return false;
    return !normalized.isBefore(info.predictionWindowStart) &&
        !normalized.isAfter(info.predictionWindowEnd);
  }

  bool isNextPredictedOvulationDay(DateTime date) {
    final expected = nextExpectedOvulationDate;
    if (expected == null) return false;
    final normalized = _dateOnly(date);
    if (normalized.isBefore(_dateOnly(_now()))) return false;
    return normalized.difference(expected).inDays.abs() <= 1;
  }

  bool isSameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  Future<bool> updateCycleSettings({
    required int cycleLength,
    required int periodDuration,
  }) async {
    final oldCycleLength = _cycleLength;
    final oldPeriodDuration = _periodDuration;
    _cycleLength = cycleLength.clamp(15, 60).toInt();
    _periodDuration = periodDuration.clamp(1, 10).toInt();
    notifyListeners();
    try {
      await _saveCycleSettings();
      return true;
    } catch (_) {
      _cycleLength = oldCycleLength;
      _periodDuration = oldPeriodDuration;
      _setError('Döngü ayarları kaydedilemedi.');
      return false;
    }
  }

  DailyLog getLogForDate(DateTime date) {
    final key = formatDateKey(date);
    return _dailyLogs[key] ?? DailyLog(dateKey: key);
  }

  Future<bool> saveDailyLog(DailyLog log) async {
    final previous = _dailyLogs[log.dateKey];
    if (log.isEmpty) {
      _dailyLogs.remove(log.dateKey);
    } else {
      _dailyLogs[log.dateKey] = log;
    }
    notifyListeners();

    try {
      if (log.isEmpty) {
        await _repository.deleteDailyLog(log.dateKey);
      } else {
        await _repository.saveDailyLog(log);
      }
      return true;
    } catch (_) {
      if (previous == null) {
        _dailyLogs.remove(log.dateKey);
      } else {
        _dailyLogs[log.dateKey] = previous;
      }
      _setError('Günlük kayıt güvenli depolamaya yazılamadı.');
      return false;
    }
  }

  Future<bool> clearAllData() async {
    _isSaving = true;
    notifyListeners();
    try {
      await _repository.clearAllData();
      _periodHistory = [];
      _dailyLogs = {};
      _cycleLength = 28;
      _periodDuration = 5;
      _errorMessage = null;
      return true;
    } catch (_) {
      _setError('Veriler silinemedi. Lütfen tekrar deneyin.');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _saveCycleSettings() => _repository.saveCycleSettings(
    periodHistory: _periodHistory,
    cycleLength: _cycleLength,
    periodDuration: _periodDuration,
    isBoyfriendMode: true,
  );

  void _applySnapshot(AppDataSnapshot snapshot) {
    _periodHistory = snapshot.periodHistory.map(_dateOnly).toSet().toList();
    _sortHistory();
    _cycleLength = snapshot.cycleLength;
    _periodDuration = snapshot.periodDuration;
    _dailyLogs = Map<String, DailyLog>.from(snapshot.dailyLogs);
  }

  void _sortHistory() => _periodHistory.sort((a, b) => b.compareTo(a));

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String formatDateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
