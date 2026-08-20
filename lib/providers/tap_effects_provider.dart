import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../data/repositories/app_repository.dart';
import '../models/tap_heart.dart';

class TapEffectsProvider with ChangeNotifier {
  final AppRepository _repository;
  List<TapHeart> _hearts;

  TapEffectsProvider(this._repository, AppDataSnapshot snapshot)
    : _hearts = List.of(snapshot.tapHearts);

  UnmodifiableListView<TapHeart> heartsFor(String surfaceId) =>
      UnmodifiableListView(
        _hearts.where((heart) => heart.surfaceId == surfaceId),
      );

  Future<void> toggleHeart(String surfaceId, double x, double y) async {
    final existingIndex = _hearts.indexWhere(
      (heart) =>
          heart.surfaceId == surfaceId &&
          (heart.x - x).abs() < 0.045 &&
          (heart.y - y).abs() < 0.055,
    );
    final previous = List<TapHeart>.of(_hearts);
    if (existingIndex >= 0) {
      _hearts.removeAt(existingIndex);
    } else {
      _hearts.add(
        TapHeart(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          surfaceId: surfaceId,
          x: x.clamp(0.0, 1.0).toDouble(),
          y: y.clamp(0.0, 1.0).toDouble(),
        ),
      );
    }
    notifyListeners();
    try {
      await _repository.saveTapHearts(_hearts);
    } catch (_) {
      _hearts = previous;
      notifyListeners();
    }
  }
}
