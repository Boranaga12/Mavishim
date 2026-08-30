import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';

import '../../providers/game_provider.dart';

class MinesweeperGameView extends StatefulWidget {
  const MinesweeperGameView({super.key});

  @override
  State<MinesweeperGameView> createState() => _MinesweeperGameViewState();
}

class _MinesweeperGameViewState extends State<MinesweeperGameView> {
  static const _side = 8;
  static const _mineCount = 10;
  final _random = Random();
  late List<_MineCell> _cells;
  bool _flagMode = false;
  bool _gameOver = false;
  bool _won = false;
  bool _minesPlaced = false;
  int _wins = 0;
  late ConfettiController _confetti;
  bool get _nightMode => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _wins = context.read<GameProvider>().progressFor('minesweeper');
    _confetti = ConfettiController(duration: const Duration(milliseconds: 900));
    _newGame();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  void _newGame() {
    _cells = List.generate(_side * _side, (_) => _MineCell());
    _minesPlaced = false;
    _flagMode = false;
    _gameOver = false;
    _won = false;
  }

  void _placeMines(int firstIndex) {
    final protected = {firstIndex, ..._neighbors(firstIndex)};
    final places = <int>{};
    while (places.length < _mineCount) {
      final candidate = _random.nextInt(_cells.length);
      if (!protected.contains(candidate)) places.add(candidate);
    }
    for (final index in places) {
      _cells[index].isMine = true;
    }
    for (var index = 0; index < _cells.length; index++) {
      _cells[index].nearbyMines = _neighbors(
        index,
      ).where((neighbor) => _cells[neighbor].isMine).length;
    }
    _minesPlaced = true;
  }

  Iterable<int> _neighbors(int index) sync* {
    final row = index ~/ _side;
    final column = index % _side;
    for (var rowDelta = -1; rowDelta <= 1; rowDelta++) {
      for (var columnDelta = -1; columnDelta <= 1; columnDelta++) {
        if (rowDelta == 0 && columnDelta == 0) continue;
        final nextRow = row + rowDelta;
        final nextColumn = column + columnDelta;
        if (nextRow >= 0 &&
            nextRow < _side &&
            nextColumn >= 0 &&
            nextColumn < _side) {
          yield nextRow * _side + nextColumn;
        }
      }
    }
  }

  void _tapCell(int index) {
    if (_gameOver || _cells[index].isRevealed) return;
    if (!_minesPlaced && !_flagMode) _placeMines(index);
    setState(() {
      final cell = _cells[index];
      if (_flagMode) {
        cell.isFlagged = !cell.isFlagged;
        return;
      }
      if (cell.isFlagged) return;
      if (cell.isMine) {
        _gameOver = true;
        for (final mine in _cells.where((item) => item.isMine)) {
          mine.isRevealed = true;
        }
        return;
      }
      _reveal(index);
      _won = _cells
          .where((item) => !item.isMine)
          .every((item) => item.isRevealed);
      _gameOver = _won;
      if (_won) {
        _wins++;
        context.read<GameProvider>().saveProgress('minesweeper', _wins);
        _confetti.play();
      }
    });
    if (_gameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showResult());
    }
  }

  Future<void> _showResult({bool stopped = false}) async {
    if (!mounted) return;
    if (stopped) {
      final opened = _cells
          .where((cell) => cell.isRevealed && !cell.isMine)
          .length;
      if (opened == 0 && !_cells.any((cell) => cell.isFlagged)) {
        Navigator.of(context).pop();
        return;
      }
      await context.read<GameProvider>().saveProgress(
        'minesweeper_partial',
        opened,
      );
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        title: const Text('Oyun bitti'),
        content: Text('Galibiyet: $_wins • Maksimum: $_wins'),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Geri çık'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(_newGame);
            },
            child: const Text('Tekrar oyna'),
          ),
        ],
      ),
    );
  }

  void _reveal(int index) {
    final cell = _cells[index];
    if (cell.isRevealed || cell.isFlagged || cell.isMine) return;
    cell.isRevealed = true;
    if (cell.nearbyMines == 0) {
      for (final neighbor in _neighbors(index)) {
        _reveal(neighbor);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final flags = _cells.where((cell) => cell.isFlagged).length;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showResult(stopped: true);
      },
      child: Scaffold(
        backgroundColor: _nightMode
            ? const Color(0xFF101725)
            : const Color(0xFFFFEEF5),
        appBar: AppBar(
          backgroundColor: _nightMode ? const Color(0xFF101725) : null,
          foregroundColor: _nightMode ? Colors.white : null,
          title: const Text('Mayın Tarlası'),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text('Maksimum: $_wins'),
              ),
            ),
            const SizedBox(width: 52),
          ],
        ),
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Mayın: $_mineCount • Galibiyet: $_wins'),
                        FilledButton.tonalIcon(
                          onPressed: () =>
                              setState(() => _flagMode = !_flagMode),
                          icon: Icon(
                            _flagMode ? Icons.flag : Icons.flag_outlined,
                          ),
                          label: Text('Bayrak: $flags'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _cells.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: _side,
                                  crossAxisSpacing: 3,
                                  mainAxisSpacing: 3,
                                ),
                            itemBuilder: (_, index) => _cell(index),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(int index) {
    final cell = _cells[index];
    final content = cell.isRevealed
        ? cell.isMine
              ? const Icon(Icons.close, color: Colors.red)
              : Text(
                  cell.nearbyMines == 0 ? '' : '${cell.nearbyMines}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
        : cell.isFlagged
        ? const Icon(Icons.flag, color: Colors.pink)
        : null;
    return Semantics(
      button: true,
      label: 'Mayın tarlası kutusu ${index + 1}',
      child: InkWell(
        onTap: () => _tapCell(index),
        child: Ink(
          decoration: BoxDecoration(
            color: cell.isRevealed
                ? _nightMode
                      ? const Color(0xFF27364B)
                      : Colors.white
                : const Color(0xFFFF81B5),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(child: content),
        ),
      ),
    );
  }
}

class _MineCell {
  bool isMine = false;
  bool isRevealed = false;
  bool isFlagged = false;
  int nearbyMines = 0;
}
