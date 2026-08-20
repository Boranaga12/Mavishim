import 'dart:math';

import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    _cells = List.generate(_side * _side, (_) => _MineCell());
    final places = <int>{};
    while (places.length < _mineCount) {
      places.add(_random.nextInt(_cells.length));
    }
    for (final index in places) {
      _cells[index].isMine = true;
    }
    for (var index = 0; index < _cells.length; index++) {
      _cells[index].nearbyMines = _neighbors(
        index,
      ).where((neighbor) => _cells[neighbor].isMine).length;
    }
    _flagMode = false;
    _gameOver = false;
    _won = false;
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
    });
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFEEF5),
      appBar: AppBar(
        title: const Text('Mayın Tarlası'),
        actions: [
          IconButton(
            onPressed: () => setState(_newGame),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mayın: $_mineCount'),
                  FilledButton.tonalIcon(
                    onPressed: () => setState(() => _flagMode = !_flagMode),
                    icon: Icon(_flagMode ? Icons.flag : Icons.flag_outlined),
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
              if (_gameOver)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _won ? 'Kazandın! ✨' : 'Mayına bastın!',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
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
            color: cell.isRevealed ? Colors.white : const Color(0xFFFF81B5),
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
