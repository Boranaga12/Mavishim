import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../providers/game_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/wheel_management_sheet.dart';
import '../../widgets/wheel_painter.dart';

class SpinWheelGameView extends StatefulWidget {
  const SpinWheelGameView({super.key});

  @override
  State<SpinWheelGameView> createState() => _SpinWheelGameViewState();
}

class _SpinWheelGameViewState extends State<SpinWheelGameView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late ConfettiController _confettiController;

  double _currentAngle = 0;
  String? _selectedResult;
  bool _isSpinning = false;
  bool get _nightMode => Theme.of(context).brightness == Brightness.dark;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 1200),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _spinWheel(List<String> options) {
    if (_isSpinning || options.isEmpty) return;

    setState(() {
      _isSpinning = true;
      _selectedResult = null;
    });

    final double targetExtraRounds = 5.0 + _random.nextDouble() * 3.0;
    final double finalAngle = _currentAngle + (targetExtraRounds * 2 * pi);

    _animation = Tween<double>(
      begin: _currentAngle,
      end: finalAngle,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));

    _controller.forward(from: 0.0).then((_) {
      if (!mounted) return;
      _currentAngle = finalAngle % (2 * pi);

      final sliceAngle = (2 * pi) / options.length;
      final adjustedAngle = (2 * pi - (_currentAngle % (2 * pi))) % (2 * pi);
      final index = (adjustedAngle / sliceAngle).floor() % options.length;

      setState(() {
        _selectedResult = options[index];
        _isSpinning = false;
      });

      _confettiController.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final wheels = gameProvider.wheels;
    final activeWheel = gameProvider.activeWheel;
    final options = activeWheel.options;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _nightMode ? const Color(0xFF101725) : null,
        foregroundColor: _nightMode ? Colors.white : null,
        title: const Text(
          'Karar & Plan Çarkıfeleği 🎡',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.primaryPink),
            tooltip: 'Çark Seçeneklerini Yönet',
            onPressed: () => _openWheelManager(context, gameProvider),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    // Horizontal Wheel Category Selector Chips
                    SizedBox(
                      height: 38,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: wheels.length + 1,
                        itemBuilder: (context, index) {
                          if (index == wheels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: ActionChip(
                                avatar: const Icon(
                                  Icons.add,
                                  size: 16,
                                  color: AppTheme.primaryPink,
                                ),
                                label: const Text('Yeni Çark'),
                                onPressed: () => showCreateWheelDialog(
                                  context,
                                  gameProvider,
                                ),
                              ),
                            );
                          }

                          final isSelected =
                              gameProvider.activeWheelIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(wheels[index].title),
                              selected: isSelected,
                              selectedColor: AppTheme.primaryPink,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 14,
                              ),
                              onSelected: (_) {
                                if (!_isSpinning) {
                                  gameProvider.setActiveWheelIndex(index);
                                  setState(() {
                                    _selectedResult = null;
                                  });
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 46,
                              color: AppTheme.primaryPink,
                            ),
                            SizedBox(
                              width: 300,
                              height: 300,
                              child: AnimatedBuilder(
                                animation: _controller,
                                builder: (context, child) {
                                  final angle = _isSpinning
                                      ? _animation.value
                                      : _currentAngle;
                                  return Transform.rotate(
                                    angle: angle,
                                    child: child,
                                  );
                                },
                                child: Semantics(
                                  image: true,
                                  label:
                                      'Karar çarkı. Seçenekler: ${options.join(', ')}',
                                  child: RepaintBoundary(
                                    child: CustomPaint(
                                      size: const Size(300, 300),
                                      painter: WheelPainter(options: options),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Result card
                    if (_selectedResult != null)
                      GlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          children: [
                            Text(
                              '🎉 Bugünün Kararı:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedResult!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryPink,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(
                              Icons.touch_app,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: Text(
                              _isSpinning ? 'Dönüyor...' : 'Çarkı Döndür! 🚀',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryPink,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _isSpinning
                                ? null
                                : () => _spinWheel(options),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.pink.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.tune,
                              color: AppTheme.primaryPink,
                              size: 20,
                            ),
                          ),
                          tooltip: 'Seçenekleri & Çarkı Yönet',
                          onPressed: () =>
                              _openWheelManager(context, gameProvider),
                        ),
                      ],
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
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openWheelManager(
    BuildContext context,
    GameProvider provider,
  ) async {
    await showWheelManagementSheet(context, provider);
    if (!mounted) return;
    setState(() => _selectedResult = null);
  }
}
