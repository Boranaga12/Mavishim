import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/game_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/tap_effects_layer.dart';
import 'couple_quiz_game.dart';
import 'memory_game.dart';
import 'minesweeper_game.dart';
import 'pink_mini_games.dart';
import 'spin_wheel_game.dart';

class GamesHubView extends StatelessWidget {
  const GamesHubView({super.key});

  @override
  Widget build(BuildContext context) {
    final scores = context.select<GameProvider, (int, int)>(
      (provider) => (provider.quizBestScore, provider.memoryBestScore),
    );
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Eğlence & Oyunlar 🎮',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF331B29),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kısa, rahat ve keyifli oyunlar.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      _card(
                        context,
                        'Karar & Plan Çarkıfeleği 🎡',
                        'Evde ne yapılacağına bir çevirişte karar ver.',
                        Icons.pie_chart_outline_rounded,
                        AppTheme.primaryPink,
                        'Karar zamanı',
                        'wheel',
                        const SpinWheelGameView(),
                      ),
                      const SizedBox(height: 12),
                      _card(
                        context,
                        'Onu Ne Kadar Tanıyorsun? 💌',
                        'Sorularla ne kadar dikkatli olduğunu dene.',
                        Icons.quiz_rounded,
                        Colors.purple,
                        'En yüksek: %${scores.$1}',
                        'quiz',
                        const CoupleQuizGameView(),
                      ),
                      const SizedBox(height: 12),
                      _card(
                        context,
                        'Hafıza Kartları 🃏',
                        'Eşleşen simgeleri bul.',
                        Icons.grid_view_rounded,
                        Colors.teal,
                        scores.$2 > 0 ? 'Rekor: ${scores.$2}' : 'Oyna',
                        'memory',
                        const MemoryGameView(),
                      ),
                      const SizedBox(height: 12),
                      _card(
                        context,
                        'Renk Avı',
                        'Farklı renk kutucuğunu bul; seviyeler sonsuza dek zorlaşır.',
                        Icons.palette_rounded,
                        AppTheme.primaryPink,
                        'Oyna',
                        'color-hunt',
                        const ColorHuntGameView(),
                      ),
                      const SizedBox(height: 12),
                      _card(
                        context,
                        'Mayın Tarlası',
                        'Mayınlara basmadan güvenli kutuları aç.',
                        Icons.grid_4x4_rounded,
                        Colors.indigo,
                        'Oyna',
                        'minesweeper',
                        const MinesweeperGameView(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    String badge,
    String surfaceId,
    Widget page,
  ) => GlassCard(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => TapEffectsLayer(surfaceId: surfaceId, child: page),
      ),
    ),
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, size: 28, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(description, style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          badge,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
