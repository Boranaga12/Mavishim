import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';

/// Named sound groups used throughout the app.
///
/// Put matching files in `assets/audio/`; a missing recording is deliberately
/// ignored so the app stays usable while the voice pack is being prepared.
enum AppSound {
  uiTap('ui_tap'),
  uiBack('ui_back'),
  uiOpen('ui_open'),
  gameStart('game_start'),
  gameCorrect('game_correct'),
  gameWrong('game_wrong'),
  gameWin('game_win'),
  gameLose('game_lose'),
  gameRecord('game_record'),
  gameCountdown('game_countdown'),
  gameShot('game_shot'),
  gameNear('game_near'),
  gameHit('game_hit'),
  wheelSpin('wheel_spin'),
  wheelResult('wheel_result');

  final String stem;
  const AppSound(this.stem);
}

enum AppMusic {
  menu('menu_music'),
  game('game_music'),
  tension('game_tension'),
  romance('romance_music');

  final String stem;
  const AppMusic(this.stem);
}

class AppAudio {
  AppAudio._();

  static final AppAudio instance = AppAudio._();
  final Random _random = Random();
  AudioPlayer? _musicPlayer;

  double _volume = .8;
  AppMusic? _activeMusic;

  double get volume => _volume;

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0, 1).toDouble();
    try {
      await _musicPlayer?.setVolume(_volume);
    } catch (_) {
      // A platform may not have initialised audio yet.
    }
  }

  /// Plays a random variant: `ui_tap_01.mp3` through `ui_tap_03.mp3`.
  Future<void> play(AppSound sound) => _playOneShot(_variantPath(sound.stem));

  /// Starts a looping random music variation. It is opt-in because browsers
  /// block autoplay before a user interaction.
  Future<void> playMusic(AppMusic music) async {
    if (_volume == 0 || _activeMusic == music) return;
    _activeMusic = music;
    try {
      final player = _musicPlayer ??= AudioPlayer();
      await player.stop();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource(_variantPath(music.stem)), volume: _volume);
    } catch (_) {
      _activeMusic = null;
    }
  }

  Future<void> stopMusic() async {
    _activeMusic = null;
    try {
      await _musicPlayer?.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _musicPlayer?.dispose();
    _musicPlayer = null;
  }

  String _variantPath(String stem) =>
      'audio/${stem}_${(_random.nextInt(3) + 1).toString().padLeft(2, '0')}.mp3';

  Future<void> _playOneShot(String path) async {
    if (_volume == 0) return;
    final player = AudioPlayer();
    try {
      await player.setReleaseMode(ReleaseMode.stop);
      await player.play(AssetSource(path), volume: _volume);
      unawaited(player.onPlayerComplete.first.then((_) => player.dispose()));
    } catch (_) {
      await player.dispose();
    }
  }
}
