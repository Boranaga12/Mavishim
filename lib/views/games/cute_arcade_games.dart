import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/game_provider.dart';

enum CuteArcadeGame {
  patternMemory,
  spotDifference,
  quickTap,
  maze,
  slidingPuzzle,
  wordHunt,
  numberMerge,
  reaction,
  balloonMatch,
  miniSudoku,
  drawPath,
  targetShot,
  emojiPuzzle,
  rhythm,
}

extension CuteArcadeGameInfo on CuteArcadeGame {
  String get title => switch (this) {
    CuteArcadeGame.patternMemory => 'Desen Hafızası',
    CuteArcadeGame.spotDifference => 'Farkı Bul',
    CuteArcadeGame.quickTap => 'Hızlı Dokun',
    CuteArcadeGame.maze => 'Pembe Labirent',
    CuteArcadeGame.slidingPuzzle => 'Kaydırmalı Yapboz',
    CuteArcadeGame.wordHunt => 'Kelime Avı',
    CuteArcadeGame.numberMerge => 'Sayı Birleştirme',
    CuteArcadeGame.reaction => 'Tepki Testi',
    CuteArcadeGame.balloonMatch => 'Balon Eşleştirme',
    CuteArcadeGame.miniSudoku => 'Mini Sudoku',
    CuteArcadeGame.drawPath => 'Yol Çiz',
    CuteArcadeGame.targetShot => 'Hedefe Atış',
    CuteArcadeGame.emojiPuzzle => 'Emoji Bulmaca',
    CuteArcadeGame.rhythm => 'Ritmi Yakala',
  };

  String get description => switch (this) {
    CuteArcadeGame.patternMemory => 'Parlayan kutuların sırasını tekrarla.',
    CuteArcadeGame.spotDifference => 'Kalabalığın içindeki farklı şekli bul.',
    CuteArcadeGame.quickTap => 'Hareket eden hedefi süre dolmadan yakala.',
    CuteArcadeGame.maze => 'Pembe noktayı engellere değmeden çıkışa götür.',
    CuteArcadeGame.slidingPuzzle =>
      'Sekiz parçayı kaydırıp doğru sıraya getir.',
    CuteArcadeGame.wordHunt => 'Karışık harflerden doğru kelimeyi oluştur.',
    CuteArcadeGame.numberMerge =>
      'Aynı sayıları seçip daha büyük sayıya birleştir.',
    CuteArcadeGame.reaction =>
      'Ekran yeşil olduğunda olabildiğince hızlı dokun.',
    CuteArcadeGame.balloonMatch => 'Aynı renkteki balon çiftlerini eşleştir.',
    CuteArcadeGame.miniSudoku => '4×4 tabloyu 1–4 sayılarıyla tamamla.',
    CuteArcadeGame.drawPath => 'Noktaları sırayla birleştirerek yolu tamamla.',
    CuteArcadeGame.targetShot => 'Nişangâhı hedefe getirip atış yap.',
    CuteArcadeGame.emojiPuzzle =>
      'Benzer emojiler arasındaki farklı olanı bul.',
    CuteArcadeGame.rhythm => 'Yanan renklerin ritmini aynı sırayla tekrarla.',
  };

  IconData get icon => switch (this) {
    CuteArcadeGame.patternMemory => Icons.apps_rounded,
    CuteArcadeGame.spotDifference => Icons.search_rounded,
    CuteArcadeGame.quickTap => Icons.touch_app_rounded,
    CuteArcadeGame.maze => Icons.route_rounded,
    CuteArcadeGame.slidingPuzzle => Icons.extension_rounded,
    CuteArcadeGame.wordHunt => Icons.spellcheck_rounded,
    CuteArcadeGame.numberMerge => Icons.add_box_rounded,
    CuteArcadeGame.reaction => Icons.bolt_rounded,
    CuteArcadeGame.balloonMatch => Icons.bubble_chart_rounded,
    CuteArcadeGame.miniSudoku => Icons.grid_4x4_rounded,
    CuteArcadeGame.drawPath => Icons.gesture_rounded,
    CuteArcadeGame.targetShot => Icons.gps_fixed_rounded,
    CuteArcadeGame.emojiPuzzle => Icons.emoji_emotions_rounded,
    CuteArcadeGame.rhythm => Icons.music_note_rounded,
  };
}

class CuteArcadeGameView extends StatefulWidget {
  final CuteArcadeGame game;

  const CuteArcadeGameView({super.key, required this.game});

  @override
  State<CuteArcadeGameView> createState() => _CuteArcadeGameViewState();
}

class _CuteArcadeGameViewState extends State<CuteArcadeGameView>
    with WidgetsBindingObserver {
  final _random = Random();
  final _wordController = TextEditingController();
  Timer? _timer;
  int _score = 0;
  int _target = 0;
  int _seconds = 20;
  int _position = 0;
  int _activeTile = -1;
  int _step = 0;
  int? _firstChoice;
  double _aim = 0.5;
  double _targetAim = 0.5;
  bool _ready = false;
  bool _inputEnabled = true;
  String _message = '';
  late List<int> _board;
  List<int> _sequence = [];
  final Set<int> _revealed = {};
  final Set<int> _matched = {};

  String get _progressKey => 'arcade_${widget.game.name}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _score = context.read<GameProvider>().progressFor(_progressKey);
    _resetRound();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _wordController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _timer?.cancel();
      return;
    }
    if (widget.game == CuteArcadeGame.quickTap && _seconds > 0) {
      _startCountdown();
    } else if (widget.game == CuteArcadeGame.reaction) {
      _scheduleReaction();
    }
  }

  void _persistScore(int value) {
    _score = value;
    context.read<GameProvider>().saveProgress(_progressKey, value);
  }

  void _resetRound() {
    _timer?.cancel();
    _seconds = 20;
    _position = 0;
    _step = 0;
    _firstChoice = null;
    _activeTile = -1;
    _ready = false;
    _inputEnabled = true;
    _message = '';
    _revealed.clear();
    _matched.clear();
    _board = List.generate(36, (index) => index);
    switch (widget.game) {
      case CuteArcadeGame.patternMemory:
        _sequence = List.generate(
          min(3 + _score, 9),
          (_) => _random.nextInt(9),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) => _showSequence());
      case CuteArcadeGame.spotDifference:
      case CuteArcadeGame.emojiPuzzle:
        _target = _random.nextInt(36);
      case CuteArcadeGame.quickTap:
        _target = _random.nextInt(30);
        _startCountdown();
      case CuteArcadeGame.maze:
        _target = 24;
      case CuteArcadeGame.slidingPuzzle:
        _board = List.generate(9, (index) => index);
        for (var i = 0; i < 120; i++) {
          final blank = _board.indexOf(0);
          final choices = _adjacent(blank, 3);
          final next = choices[_random.nextInt(choices.length)];
          final value = _board[next];
          _board[next] = 0;
          _board[blank] = value;
        }
      case CuteArcadeGame.wordHunt:
        _target = _random.nextInt(_words.length);
        _wordController.clear();
      case CuteArcadeGame.numberMerge:
        _board = List.generate(16, (_) => _random.nextBool() ? 2 : 4);
      case CuteArcadeGame.reaction:
        _scheduleReaction();
      case CuteArcadeGame.balloonMatch:
        _board = [...List.generate(6, (i) => i), ...List.generate(6, (i) => i)]
          ..shuffle(_random);
      case CuteArcadeGame.miniSudoku:
        _board = [1, 0, 3, 0, 0, 4, 0, 2, 2, 0, 4, 0, 0, 3, 0, 1];
      case CuteArcadeGame.drawPath:
        _sequence = [0, 1, 6, 7, 12, 13, 18, 19, 24];
      case CuteArcadeGame.targetShot:
        _targetAim = 0.12 + _random.nextDouble() * 0.76;
      case CuteArcadeGame.rhythm:
        _sequence = List.generate(
          min(3 + _score, 10),
          (_) => _random.nextInt(4),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) => _showSequence());
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _seconds--;
        if (_seconds <= 0) {
          _timer?.cancel();
          _message = 'Süre doldu • Puanın: $_score';
        }
      });
    });
  }

  Future<void> _showSequence() async {
    if (!mounted) return;
    setState(() => _inputEnabled = false);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    for (final tile in _sequence) {
      if (!mounted) return;
      setState(() => _activeTile = tile);
      await Future<void>.delayed(const Duration(milliseconds: 420));
      if (!mounted) return;
      setState(() => _activeTile = -1);
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
    if (mounted) setState(() => _inputEnabled = true);
  }

  void _sequenceTap(int index) {
    if (!_inputEnabled) return;
    if (_sequence[_step] != index) {
      setState(() {
        _message = 'Sıra karıştı, yeniden gösteriliyor.';
        _step = 0;
      });
      _showSequence();
      return;
    }
    _step++;
    if (_step == _sequence.length) {
      _persistScore(_score + 1);
      setState(_resetRound);
    } else {
      setState(() {});
    }
  }

  void _pickDifference(int index) {
    if (index != _target) {
      setState(() => _message = 'Çok yakın, bir daha bak 🌸');
      return;
    }
    _persistScore(_score + 1);
    setState(_resetRound);
  }

  void _quickTap(int index) {
    if (_seconds <= 0 || index != _target) return;
    _persistScore(_score + 1);
    setState(() => _target = _random.nextInt(30));
  }

  void _move(int delta) {
    const walls = {6, 7, 8, 13, 16, 18};
    final next = _position + delta;
    final wraps =
        (delta == 1 && _position % 5 == 4) ||
        (delta == -1 && _position % 5 == 0);
    if (next < 0 || next >= 25 || wraps || walls.contains(next)) return;
    setState(() => _position = next);
    context.read<GameProvider>().saveProgress('${_progressKey}_position', next);
    if (next == _target) {
      _persistScore(_score + 1);
      setState(() {
        _position = 0;
        _message = 'Çıkışı buldun! ✨';
      });
    }
  }

  List<int> _adjacent(int index, int side) => [
    if (index ~/ side > 0) index - side,
    if (index ~/ side < side - 1) index + side,
    if (index % side > 0) index - 1,
    if (index % side < side - 1) index + 1,
  ];

  void _slide(int index) {
    final blank = _board.indexOf(0);
    if (!_adjacent(blank, 3).contains(index)) return;
    setState(() {
      _board[blank] = _board[index];
      _board[index] = 0;
    });
    if (_board.join(',') == '1,2,3,4,5,6,7,8,0') {
      _persistScore(_score + 1);
      setState(() => _message = 'Yapboz tamamlandı! ✨');
    }
  }

  void _checkWord() {
    final answer = _wordController.text.trim().toUpperCase();
    if (answer == _words[_target]) {
      _persistScore(_score + 1);
      setState(_resetRound);
    } else {
      setState(() => _message = 'Bu olmadı, harflere tekrar bak.');
    }
  }

  void _merge(int index) {
    if (_firstChoice == null) {
      setState(() => _firstChoice = index);
      return;
    }
    final first = _firstChoice!;
    if (first != index && _board[first] == _board[index]) {
      setState(() {
        _board[index] *= 2;
        _board[first] = _random.nextBool() ? 2 : 4;
        _firstChoice = null;
      });
      _persistScore(max(_score, _board[index]));
    } else {
      setState(() => _firstChoice = index);
    }
  }

  void _scheduleReaction() {
    _ready = false;
    _message = 'Bekle…';
    _timer = Timer(Duration(milliseconds: 900 + _random.nextInt(2200)), () {
      if (mounted) {
        setState(() {
          _ready = true;
          _message = 'ŞİMDİ!';
        });
      }
    });
  }

  void _reactionTap() {
    if (!_ready) {
      _timer?.cancel();
      setState(() => _message = 'Biraz erken dokundun.');
      Future<void>.delayed(
        const Duration(milliseconds: 700),
        _scheduleReaction,
      );
      return;
    }
    _persistScore(_score + 1);
    setState(_scheduleReaction);
  }

  void _matchBalloon(int index) {
    if (_matched.contains(index) || _revealed.contains(index)) return;
    setState(() => _revealed.add(index));
    if (_firstChoice == null) {
      _firstChoice = index;
      return;
    }
    final first = _firstChoice!;
    _firstChoice = null;
    if (_board[first] == _board[index]) {
      setState(() => _matched.addAll([first, index]));
      _persistScore(_score + 1);
      if (_matched.length == _board.length) setState(_resetRound);
    } else {
      Future<void>.delayed(const Duration(milliseconds: 650), () {
        if (mounted) setState(() => _revealed.removeAll([first, index]));
      });
    }
  }

  void _sudokuTap(int index) {
    const fixed = {0, 2, 5, 7, 8, 10, 13, 15};
    if (fixed.contains(index)) return;
    setState(() => _board[index] = _board[index] % 4 + 1);
    context.read<GameProvider>().saveProgress(
      '${_progressKey}_moves',
      _score + 1,
    );
    const solution = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1];
    if (_board.join(',') == solution.join(',')) {
      _persistScore(_score + 1);
      setState(() => _message = 'Sudoku tamamlandı! 🌸');
    }
  }

  void _pathTap(int index) {
    if (_step >= _sequence.length || _sequence[_step] != index) {
      setState(() {
        _step = 0;
        _message = 'Yol koptu; ilk noktadan başla.';
      });
      return;
    }
    setState(() => _step++);
    if (_step == _sequence.length) {
      _persistScore(_score + 1);
      setState(() {
        _step = 0;
        _message = 'Yol tamamlandı! ✨';
      });
    }
  }

  void _shoot() {
    final distance = (_aim - _targetAim).abs();
    if (distance < 0.06) _persistScore(_score + 1);
    setState(() {
      _message = distance < 0.06 ? 'Tam isabet! 🎯' : 'Biraz daha yaklaş.';
      _targetAim = 0.12 + _random.nextDouble() * 0.76;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.title),
        actions: [
          Center(child: Text('Puan $_score')),
          IconButton(
            onPressed: () => setState(_resetRound),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(widget.game.description, textAlign: TextAlign.center),
                if (_message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      _message,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 10),
                Expanded(child: _gameBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gameBody() => switch (widget.game) {
    CuteArcadeGame.patternMemory => _sequenceGrid(9),
    CuteArcadeGame.spotDifference => _differenceGrid(false),
    CuteArcadeGame.quickTap => _quickGrid(),
    CuteArcadeGame.maze => _maze(),
    CuteArcadeGame.slidingPuzzle => _sliding(),
    CuteArcadeGame.wordHunt => _wordHunt(),
    CuteArcadeGame.numberMerge => _mergeGrid(),
    CuteArcadeGame.reaction => _reaction(),
    CuteArcadeGame.balloonMatch => _balloons(),
    CuteArcadeGame.miniSudoku => _sudoku(),
    CuteArcadeGame.drawPath => _path(),
    CuteArcadeGame.targetShot => _targetGame(),
    CuteArcadeGame.emojiPuzzle => _differenceGrid(true),
    CuteArcadeGame.rhythm => _sequenceGrid(4),
  };

  Widget _grid(int count, int columns, Widget Function(int) child) =>
      GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (_, index) => child(index),
      );

  Widget _sequenceGrid(int count) => _grid(
    count,
    count == 4 ? 2 : 3,
    (index) => _tile(
      color: _activeTile == index ? AppTheme.primaryPink : Colors.white,
      onTap: () => _sequenceTap(index),
      child: Icon(
        widget.game == CuteArcadeGame.rhythm
            ? Icons.music_note
            : Icons.favorite,
        color: _activeTile == index ? Colors.white : Colors.pink.shade200,
      ),
    ),
  );

  Widget _differenceGrid(bool emoji) => _grid(
    36,
    6,
    (index) => _tile(
      onTap: () => _pickDifference(index),
      child: Text(
        emoji
            ? (index == _target ? '😺' : '😸')
            : (index == _target ? '◆' : '●'),
        style: const TextStyle(fontSize: 24),
      ),
    ),
  );

  Widget _quickGrid() => Column(
    children: [
      Text('Süre: $_seconds sn'),
      const SizedBox(height: 10),
      Expanded(
        child: _grid(
          30,
          5,
          (index) => _tile(
            onTap: () => _quickTap(index),
            color: index == _target ? AppTheme.primaryPink : Colors.white,
            child: index == _target
                ? const Icon(Icons.favorite, color: Colors.white)
                : null,
          ),
        ),
      ),
    ],
  );

  Widget _maze() => Column(
    children: [
      Expanded(
        child: _grid(25, 5, (index) {
          const walls = {6, 7, 8, 13, 16, 18};
          return _tile(
            color: walls.contains(index) ? Colors.pink.shade200 : Colors.white,
            child: index == _position
                ? const Icon(Icons.circle, color: AppTheme.primaryPink)
                : index == _target
                ? const Icon(Icons.flag, color: Colors.green)
                : null,
          );
        }),
      ),
      Wrap(
        children: [
          IconButton(
            onPressed: () => _move(-5),
            icon: const Icon(Icons.arrow_upward),
          ),
          IconButton(
            onPressed: () => _move(-1),
            icon: const Icon(Icons.arrow_back),
          ),
          IconButton(
            onPressed: () => _move(1),
            icon: const Icon(Icons.arrow_forward),
          ),
          IconButton(
            onPressed: () => _move(5),
            icon: const Icon(Icons.arrow_downward),
          ),
        ],
      ),
    ],
  );

  Widget _sliding() => _grid(
    9,
    3,
    (index) => _board[index] == 0
        ? const SizedBox()
        : _tile(
            onTap: () => _slide(index),
            color: AppTheme.primaryPink,
            child: Text(
              '${_board[index]}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
  );

  static const _words = ['MAVİ', 'PEMBE', 'ÇİÇEK', 'YILDIZ', 'BULUT', 'MASAL'];
  Widget _wordHunt() {
    final mixed = _words[_target].split('')..shuffle(Random(_target));
    return Column(
      children: [
        Wrap(
          spacing: 8,
          children: mixed
              .map(
                (letter) => Chip(
                  label: Text(letter, style: const TextStyle(fontSize: 24)),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _wordController,
          textCapitalization: TextCapitalization.characters,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(labelText: 'Kelimeyi yaz'),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: _checkWord, child: const Text('Kontrol et')),
      ],
    );
  }

  Widget _mergeGrid() => _grid(
    16,
    4,
    (index) => _tile(
      onTap: () => _merge(index),
      color: _firstChoice == index
          ? Colors.purple.shade300
          : Colors.pink.shade100,
      child: Text(
        '${_board[index]}',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ),
  );

  Widget _reaction() => Center(
    child: GestureDetector(
      onTap: _reactionTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _ready ? Colors.green : AppTheme.primaryPink,
        ),
        child: Center(
          child: Text(
            _ready ? 'DOKUN!' : 'BEKLE',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );

  Widget _balloons() => _grid(12, 3, (index) {
    final open = _revealed.contains(index) || _matched.contains(index);
    return _tile(
      onTap: () => _matchBalloon(index),
      color: open ? Colors.white : AppTheme.primaryPink,
      child: open
          ? Text(
              ['🎈', '🌸', '⭐', '🍓', '🦋', '🍬'][_board[index]],
              style: const TextStyle(fontSize: 30),
            )
          : const Icon(Icons.question_mark, color: Colors.white),
    );
  });

  Widget _sudoku() => _grid(
    16,
    4,
    (index) => _tile(
      onTap: () => _sudokuTap(index),
      color: Colors.white,
      child: Text(
        _board[index] == 0 ? '' : '${_board[index]}',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
  );

  Widget _path() => _grid(25, 5, (index) {
    final pathIndex = _sequence.indexOf(index);
    final done = pathIndex >= 0 && pathIndex < _step;
    return _tile(
      onTap: () => _pathTap(index),
      color: done ? AppTheme.primaryPink : Colors.white,
      child: pathIndex >= 0
          ? Text(
              '${pathIndex + 1}',
              style: TextStyle(
                color: done ? Colors.white : AppTheme.primaryPink,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  });

  Widget _targetGame() => Column(
    children: [
      Expanded(
        child: LayoutBuilder(
          builder: (_, box) => Stack(
            children: [
              Positioned(
                left: _targetAim * (box.maxWidth - 70),
                top: 70,
                child: const Icon(
                  Icons.gps_fixed,
                  color: Colors.purple,
                  size: 70,
                ),
              ),
              Positioned(
                left: _aim * (box.maxWidth - 50),
                bottom: 20,
                child: const Icon(
                  Icons.favorite,
                  color: AppTheme.primaryPink,
                  size: 50,
                ),
              ),
            ],
          ),
        ),
      ),
      Slider(value: _aim, onChanged: (value) => setState(() => _aim = value)),
      FilledButton.icon(
        onPressed: _shoot,
        icon: const Icon(Icons.arrow_upward),
        label: const Text('Atış yap'),
      ),
    ],
  );

  Widget _tile({
    Widget? child,
    Color color = Colors.white,
    VoidCallback? onTap,
  }) => Material(
    color: color,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Center(child: child),
    ),
  );
}
