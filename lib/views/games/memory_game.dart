import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../providers/game_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class MemoryGameView extends StatefulWidget {
  const MemoryGameView({super.key});

  @override
  State<MemoryGameView> createState() => _MemoryGameViewState();
}

class _MemoryGameViewState extends State<MemoryGameView> {
  late ConfettiController _confettiController;

  final List<IconData> _baseIcons = const [
    Icons.favorite,
    Icons.star,
    Icons.sentiment_very_satisfied,
    Icons.card_giftcard,
    Icons.emoji_events,
    Icons.coffee,
  ];

  late List<_CardItem> _cards;
  _CardItem? _firstSelected;
  _CardItem? _secondSelected;
  bool _isProcessing = false;
  int _moves = 0;
  int _matchesFound = 0;
  bool get _nightMode => Theme.of(context).brightness == Brightness.dark;
  Timer? _flipBackTimer;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 1200),
    );
    _startNewGame(notify: false);
  }

  @override
  void dispose() {
    _flipBackTimer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _startNewGame({bool notify = true}) {
    _flipBackTimer?.cancel();
    final doubled = [..._baseIcons, ..._baseIcons]..shuffle();
    _cards = List.generate(
      doubled.length,
      (index) => _CardItem(id: index, icon: doubled[index]),
    );
    _firstSelected = null;
    _secondSelected = null;
    _isProcessing = false;
    _moves = 0;
    _matchesFound = 0;
    if (notify && mounted) setState(() {});
  }

  void _onCardTap(_CardItem card) {
    if (_isProcessing || card.isFlipped || card.isMatched) return;

    setState(() {
      card.isFlipped = true;
    });

    if (_firstSelected == null) {
      _firstSelected = card;
    } else {
      _secondSelected = card;
      _moves++;
      _isProcessing = true;

      if (_firstSelected!.icon == _secondSelected!.icon) {
        _firstSelected!.isMatched = true;
        _secondSelected!.isMatched = true;
        _matchesFound++;
        _firstSelected = null;
        _secondSelected = null;
        _isProcessing = false;

        if (_matchesFound == _baseIcons.length) {
          _confettiController.play();
          context.read<GameProvider>().updateMemoryScore(_moves);
          WidgetsBinding.instance.addPostFrameCallback((_) => _showResult());
        }
      } else {
        _flipBackTimer = Timer(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          setState(() {
            _firstSelected!.isFlipped = false;
            _secondSelected!.isFlipped = false;
            _firstSelected = null;
            _secondSelected = null;
            _isProcessing = false;
          });
        });
      }
    }
  }

  Future<void> _showResult({bool stopped = false}) async {
    if (!mounted) return;
    if (stopped && _moves == 0 && _matchesFound == 0) {
      Navigator.of(context).pop();
      return;
    }
    if (stopped && _moves > 0) {
      await context.read<GameProvider>().saveProgress('memory_partial', _moves);
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        title: const Text('Oyun bitti'),
        content: Text(
          'Hamle: $_moves • Rekor: ${context.read<GameProvider>().memoryBestScore}',
        ),
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
              _startNewGame();
            },
            child: const Text('Tekrar oyna'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bestScore = context.select<GameProvider, int>(
      (provider) => provider.memoryBestScore,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showResult(stopped: true);
      },
      child: Scaffold(
        backgroundColor: _nightMode ? const Color(0xFF101725) : null,
        appBar: AppBar(
          backgroundColor: _nightMode ? const Color(0xFF101725) : null,
          foregroundColor: _nightMode ? Colors.white : null,
          title: const Text(
            'Love Match 💖',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text('Maksimum: ${bestScore == 0 ? '-' : bestScore}'),
              ),
            ),
            const SizedBox(width: 52),
          ],
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: _nightMode ? null : AppTheme.backgroundGradient,
                color: _nightMode ? const Color(0xFF101725) : null,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GlassCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Hamle',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  '$_moves',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryPink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GlassCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'En İyi Rekor',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  bestScore == 0 ? '-' : '$bestScore',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.deepPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Expanded(
                        child: GridView.builder(
                          itemCount: _cards.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemBuilder: (context, index) {
                            final card = _cards[index];
                            return Semantics(
                              button: true,
                              enabled: !_isProcessing && !card.isMatched,
                              label: card.isMatched
                                  ? '${index + 1}. kart eşleşti'
                                  : card.isFlipped
                                  ? '${index + 1}. kart açık'
                                  : '${index + 1}. kapalı kart',
                              child: GestureDetector(
                                onTap: () => _onCardTap(card),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    color: card.isFlipped || card.isMatched
                                        ? Colors.white
                                        : AppTheme.primaryPink,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.pink.withValues(
                                          alpha: 0.15,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: card.isMatched
                                          ? AppTheme.accentGold
                                          : Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: card.isFlipped || card.isMatched
                                        ? Icon(
                                            card.icon,
                                            color: AppTheme.primaryPink,
                                            size: 36,
                                          )
                                        : const Icon(
                                            Icons.favorite,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                numberOfParticles: 10,
                emissionFrequency: 0.025,
                maxBlastForce: 12,
                minBlastForce: 5,
                colors: const [
                  Colors.pink,
                  Colors.red,
                  Colors.amber,
                  Colors.purple,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardItem {
  final int id;
  final IconData icon;
  bool isFlipped = false;
  bool isMatched = false;

  _CardItem({required this.id, required this.icon});
}
