import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../data/repositories/app_repository.dart';
import '../data/default_wheels.dart';
import '../data/quiz_questions.dart';
import '../models/wheel_model.dart';

class GameProvider with ChangeNotifier {
  final AppRepository _repository;

  late int _memoryBestScore;
  late int _quizBestScore;
  late int _activeWheelIndex;
  late List<WheelModel> _wheels;
  late List<QuizQuestion> _quizQuestions;
  late Map<String, int> _gameProgress;
  String? _errorMessage;
  Timer? _progressSaveTimer;

  GameProvider(this._repository, AppDataSnapshot snapshot) {
    _memoryBestScore = snapshot.memoryBestScore;
    _quizBestScore = snapshot.quizBestScore.clamp(0, 100).toInt();
    _wheels = snapshot.wheels.isEmpty
        ? List.of(defaultWheels)
        : List.of(snapshot.wheels);
    _activeWheelIndex = snapshot.activeWheelIndex
        .clamp(0, _wheels.length - 1)
        .toInt();
    _quizQuestions = List.of(snapshot.quizQuestions);
    _gameProgress = Map.of(snapshot.gameProgress);
  }

  int get memoryBestScore => _memoryBestScore;
  int get quizBestScore => _quizBestScore;
  int get activeWheelIndex => _activeWheelIndex;
  UnmodifiableListView<WheelModel> get wheels => UnmodifiableListView(_wheels);
  UnmodifiableListView<QuizQuestion> get quizQuestions =>
      UnmodifiableListView(_quizQuestions);
  String? get errorMessage => _errorMessage;
  int progressFor(String gameId) => _gameProgress[gameId] ?? 0;
  int get quizCursor => progressFor('quizCursor');

  WheelModel get activeWheel => _wheels[_activeWheelIndex];

  Future<void> setActiveWheelIndex(int index) async {
    if (index < 0 || index >= _wheels.length || index == _activeWheelIndex) {
      return;
    }
    final previous = _capture();
    _activeWheelIndex = index;
    notifyListeners();
    if (!await _persist()) _restore(previous);
  }

  Future<void> renameActiveWheel(String newTitle) async {
    final value = newTitle.trim();
    if (value.isEmpty) return;
    final previous = _capture();
    _replaceActive(activeWheel.copyWith(title: value));
    if (!await _persist()) _restore(previous);
  }

  Future<bool> deleteActiveWheel() async {
    if (_wheels.length <= 1) return false;
    final previous = _capture();
    _wheels.removeAt(_activeWheelIndex);
    _activeWheelIndex = _activeWheelIndex.clamp(0, _wheels.length - 1).toInt();
    notifyListeners();
    if (!await _persist()) {
      _restore(previous);
      return false;
    }
    return true;
  }

  Future<void> updateMemoryScore(int moves) async {
    if (moves <= 0 || (_memoryBestScore != 0 && moves >= _memoryBestScore)) {
      return;
    }
    final previous = _capture();
    _memoryBestScore = moves;
    notifyListeners();
    if (!await _persist()) _restore(previous);
  }

  Future<void> updateQuizScore(int percent) async {
    final normalized = percent.clamp(0, 100).toInt();
    if (normalized <= _quizBestScore) return;
    final previous = _capture();
    _quizBestScore = normalized;
    notifyListeners();
    if (!await _persist()) _restore(previous);
  }

  Future<void> saveProgress(String gameId, int value) async {
    if (_gameProgress[gameId] == value) return;
    _gameProgress[gameId] = value;
    notifyListeners();
    // Rapid-tap games can score many times per second. Coalesce those writes
    // so encryption and disk I/O never run once per frame/tap.
    _progressSaveTimer?.cancel();
    _progressSaveTimer = Timer(
      const Duration(milliseconds: 220),
      () => unawaited(_flushGameProgress()),
    );
  }

  Future<void> _flushGameProgress() async {
    _progressSaveTimer = null;
    try {
      await _repository.saveGameProgress(_gameProgress);
    } catch (_) {
      _errorMessage = 'Oyun ilerlemesi kaydedilemedi.';
      notifyListeners();
    }
  }

  Future<void> advanceQuiz() => saveProgress('quizCursor', quizCursor + 1);

  Future<void> addOptionToActiveWheel(String option) async {
    final value = option.trim();
    if (value.isEmpty) return;
    final previous = _capture();
    _replaceActive(
      activeWheel.copyWith(options: [...activeWheel.options, value]),
    );
    if (!await _persist()) _restore(previous);
  }

  Future<void> editOptionInActiveWheel(int index, String newText) async {
    final value = newText.trim();
    if (index < 0 || index >= activeWheel.options.length || value.isEmpty) {
      return;
    }
    final previous = _capture();
    final options = List<String>.from(activeWheel.options)..[index] = value;
    _replaceActive(activeWheel.copyWith(options: options));
    if (!await _persist()) _restore(previous);
  }

  Future<void> removeOptionFromActiveWheel(int index) async {
    if (activeWheel.options.length <= 2 ||
        index < 0 ||
        index >= activeWheel.options.length) {
      return;
    }
    final previous = _capture();
    final options = List<String>.from(activeWheel.options)..removeAt(index);
    _replaceActive(activeWheel.copyWith(options: options));
    if (!await _persist()) _restore(previous);
  }

  Future<void> createCustomWheel(String title, List<String> options) async {
    final cleanedOptions = options
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (title.trim().isEmpty || cleanedOptions.length < 2) return;
    final previous = _capture();
    _wheels.add(
      WheelModel(
        id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
        title: title.trim(),
        iconName: 'star',
        options: cleanedOptions,
        isCustom: true,
      ),
    );
    _activeWheelIndex = _wheels.length - 1;
    notifyListeners();
    if (!await _persist()) _restore(previous);
  }

  void resetAfterDataDeletion() {
    _memoryBestScore = 0;
    _quizBestScore = 0;
    _activeWheelIndex = 0;
    _wheels = List.of(defaultWheels);
    _quizQuestions = List.of(customQuizQuestions);
    _gameProgress = {};
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _progressSaveTimer?.cancel();
    if (_progressSaveTimer != null) {
      unawaited(_flushGameProgress());
    }
    super.dispose();
  }

  void _replaceActive(WheelModel wheel) {
    _wheels[_activeWheelIndex] = wheel;
    notifyListeners();
  }

  Future<bool> _persist() async {
    try {
      await _repository.saveGameState(
        memoryBestScore: _memoryBestScore,
        quizBestScore: _quizBestScore,
        activeWheelIndex: _activeWheelIndex,
        wheels: _wheels,
        quizQuestions: _quizQuestions,
      );
      return true;
    } catch (_) {
      _errorMessage = 'Oyun verileri güvenli depolamaya yazılamadı.';
      notifyListeners();
      return false;
    }
  }

  _GameState _capture() => _GameState(
    memoryBestScore: _memoryBestScore,
    quizBestScore: _quizBestScore,
    activeWheelIndex: _activeWheelIndex,
    wheels: List.of(_wheels),
    quizQuestions: List.of(_quizQuestions),
  );

  void _restore(_GameState state) {
    _memoryBestScore = state.memoryBestScore;
    _quizBestScore = state.quizBestScore;
    _activeWheelIndex = state.activeWheelIndex;
    _wheels = state.wheels;
    _quizQuestions = state.quizQuestions;
    notifyListeners();
  }
}

class _GameState {
  final int memoryBestScore;
  final int quizBestScore;
  final int activeWheelIndex;
  final List<WheelModel> wheels;
  final List<QuizQuestion> quizQuestions;

  const _GameState({
    required this.memoryBestScore,
    required this.quizBestScore,
    required this.activeWheelIndex,
    required this.wheels,
    required this.quizQuestions,
  });
}
