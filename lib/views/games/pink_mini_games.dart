import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/game_provider.dart';

class ColorHuntGameView extends StatefulWidget {
  const ColorHuntGameView({super.key});

  @override
  State<ColorHuntGameView> createState() => _ColorHuntGameViewState();
}

class _ColorHuntGameViewState extends State<ColorHuntGameView> {
  static const _gridSize = 6;
  final _random = Random();
  late List<int> _tiles;
  late int _oddIndex;
  late Color _baseColor;
  late Color _oddColor;
  int _level = 1;
  int _hearts = 3;
  bool _nightMode = false;
  bool _restingEyes = false;
  bool _shuffling = false;
  bool _gameOver = false;
  Timer? _restTimer;

  @override
  void initState() {
    super.initState();
    _level = max(1, context.read<GameProvider>().progressFor('colorHunt'));
    _startLevel();
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  void _startLevel() {
    final hue = _random.nextDouble() * 360;
    final lightness = 0.55 + _random.nextDouble() * 0.1;
    final saturation = 0.62 + _random.nextDouble() * 0.18;
    final difference = max(0.012, 0.19 - (_level - 1) * 0.0065);
    final direction = _random.nextBool() ? 1 : -1;
    _baseColor = HSLColor.fromAHSL(1, hue, saturation, lightness).toColor();
    _oddColor = HSLColor.fromAHSL(
      1,
      (hue + direction * difference * 180) % 360,
      (saturation - difference * 0.2).clamp(0.35, 0.95),
      (lightness + difference * 0.35).clamp(0.3, 0.78),
    ).toColor();
    _oddIndex = _random.nextInt(_gridSize * _gridSize);
    _tiles = List.generate(_gridSize * _gridSize, (index) => index);
  }

  void _select(int tile) {
    if (_gameOver || _restingEyes || _shuffling) return;
    if (tile == _oddIndex) {
      context.read<GameProvider>().saveProgress('colorHunt', _level + 1);
      setState(() {
        _level++;
        _hearts = 3;
        _startLevel();
      });
      return;
    }
    setState(() {
      _hearts--;
      _gameOver = _hearts == 0;
    });
  }

  Future<void> _shuffleTiles() async {
    if (_shuffling || _gameOver) return;
    setState(() => _shuffling = true);
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;
    setState(() {
      _tiles.shuffle(_random);
      _shuffling = false;
    });
  }

  void _restEyes() {
    if (_restingEyes || _gameOver) return;
    _restTimer?.cancel();
    setState(() => _restingEyes = true);
    _restTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _restingEyes = false);
    });
  }

  void _restart() => setState(() {
    _level = 1;
    _hearts = 3;
    _gameOver = false;
    _startLevel();
  });

  @override
  Widget build(BuildContext context) {
    final background = _nightMode
        ? const Color(0xFF101725)
        : const Color(0xFFFFEEF5);
    final foreground = _nightMode ? Colors.white : const Color(0xFF38203A);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: foreground,
        title: const Text('Renk Avı'),
        actions: [
          IconButton(onPressed: _restart, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _grid(),
              const SizedBox(height: 14),
              _controlPanel(foreground),
              if (_gameOver) _gameOverCard(foreground),
            ],
          ),
        ),
      ),
    );
  }

  Widget _grid() => Expanded(
    child: Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: AnimatedScale(
          scale: _shuffling ? 0.22 : 1,
          duration: const Duration(milliseconds: 280),
          curve: _shuffling ? Curves.easeIn : Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: _restingEyes ? 0 : 1,
            duration: const Duration(milliseconds: 350),
            child: IgnorePointer(
              ignoring: _restingEyes || _shuffling || _gameOver,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tiles.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _gridSize,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemBuilder: (_, index) {
                  final tile = _tiles[index];
                  return Semantics(
                    button: true,
                    label: 'Renk kutucuğu ${index + 1}',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () => _select(tile),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: tile == _oddIndex ? _oddColor : _baseColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _controlPanel(Color foreground) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: _nightMode ? const Color(0xFF182233) : Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        _control(Icons.shuffle_rounded, 'Karıştır', _shuffleTiles, foreground),
        _control(
          Icons.visibility_off_outlined,
          'Göz dinlendir',
          _restEyes,
          foreground,
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                'Level $_level',
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '♥' * _hearts,
                style: const TextStyle(color: Color(0xFFFF617D), fontSize: 20),
              ),
            ],
          ),
        ),
        _control(
          _nightMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          'Gece modu',
          () => setState(() => _nightMode = !_nightMode),
          foreground,
        ),
      ],
    ),
  );

  Widget _control(
    IconData icon,
    String label,
    VoidCallback action,
    Color color,
  ) => Expanded(
    child: Semantics(
      button: true,
      label: label,
      child: IconButton(
        onPressed: action,
        icon: Icon(icon, color: color),
      ),
    ),
  );

  Widget _gameOverCard(Color foreground) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Oyun bitti • Ulaşılan seviye: $_level',
                style: TextStyle(color: foreground),
              ),
            ),
            TextButton(onPressed: _restart, child: const Text('Tekrar oyna')),
          ],
        ),
      ),
    ),
  );
}
