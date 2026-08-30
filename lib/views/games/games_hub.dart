import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/game_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/tap_effects_layer.dart';
import 'couple_quiz_game.dart';
import 'cute_arcade_games.dart';
import 'memory_game.dart';
import 'minesweeper_game.dart';
import 'pink_mini_games.dart';
import 'spin_wheel_game.dart';

class GamesHubView extends StatelessWidget {
  const GamesHubView({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = _gameEntries();
    return Scaffold(
      body: DecoratedBox(
        decoration: AppTheme.pageBackground(context),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Eğlence & Oyunlar 🎮',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'İlerlemen otomatik kaydedilir; istediğin zaman devam et.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: entries.length,
                    cacheExtent: 300,
                    separatorBuilder: (_, _) => _gap,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _card(
                        context,
                        entry.title,
                        entry.description,
                        entry.icon,
                        entry.color,
                        entry.badge,
                        entry.surfaceId,
                        entry.page,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _gap = SizedBox(height: 12);

  List<_GameEntry> _gameEntries() => [
    const _GameEntry(
      title: 'Karar & Plan Çarkıfeleği 🎡',
      description: 'Evde ne yapılacağına bir çevirişte karar ver.',
      icon: Icons.pie_chart_outline_rounded,
      color: AppTheme.primaryPink,
      badge: Text('Aç'),
      surfaceId: 'wheel',
      page: SpinWheelGameView(),
    ),
    const _GameEntry(
      title: 'Onu Ne Kadar Tanıyorsun? 💌',
      description: 'Sen çıkana kadar yeni sorularla devam eder.',
      icon: Icons.quiz_rounded,
      color: Colors.purple,
      badge: _GameProgressBadge(kind: _BadgeKind.quiz),
      surfaceId: 'quiz',
      page: CoupleQuizGameView(),
    ),
    const _GameEntry(
      title: 'Hafıza Kartları 🃏',
      description: 'Eşleşen simgeleri bul.',
      icon: Icons.grid_view_rounded,
      color: Colors.teal,
      badge: _GameProgressBadge(kind: _BadgeKind.memory),
      surfaceId: 'memory',
      page: MemoryGameView(),
    ),
    const _GameEntry(
      title: 'Renk Avı',
      description: '36 kutucuk arasındaki farklı tonu yakala.',
      icon: Icons.palette_rounded,
      color: AppTheme.primaryPink,
      badge: _GameProgressBadge(progressKey: 'colorHunt'),
      surfaceId: 'color-hunt',
      page: ColorHuntGameView(),
    ),
    const _GameEntry(
      title: 'Mayın Tarlası',
      description: 'Mayınlara basmadan güvenli kutuları aç.',
      icon: Icons.grid_4x4_rounded,
      color: Colors.indigo,
      badge: _GameProgressBadge(progressKey: 'minesweeper'),
      surfaceId: 'minesweeper',
      page: MinesweeperGameView(),
    ),
    for (final game in CuteArcadeGame.values)
      _GameEntry(
        title: game.title,
        description: game.description,
        icon: game.icon,
        color: _gameColor(game.index),
        badge: _GameProgressBadge(progressKey: 'arcade_${game.name}'),
        surfaceId: 'arcade-${game.name}',
        page: CuteArcadeGameView(game: game),
      ),
  ];

  Color _gameColor(int index) => [
    const Color(0xFFFF5E9B),
    const Color(0xFFB36AE2),
    const Color(0xFF6FC8C2),
    const Color(0xFFFF9F68),
  ][index % 4];

  Widget _card(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    Widget badge,
    String surfaceId,
    Widget page,
  ) => GlassCard(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => TapEffectsLayer(
          surfaceId: surfaceId,
          allowHeartPlacement: false,
          child: page,
        ),
      ),
    ),
    padding: const EdgeInsets.all(15),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        DefaultTextStyle(
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
          child: badge,
        ),
      ],
    ),
  );
}

class _GameEntry {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget badge;
  final String surfaceId;
  final Widget page;

  const _GameEntry({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.badge,
    required this.surfaceId,
    required this.page,
  });
}

enum _BadgeKind { progress, quiz, memory }

class _GameProgressBadge extends StatelessWidget {
  final _BadgeKind kind;
  final String? progressKey;

  const _GameProgressBadge({this.kind = _BadgeKind.progress, this.progressKey});

  @override
  Widget build(BuildContext context) {
    final value = context.select<GameProvider, int>((provider) {
      return switch (kind) {
        _BadgeKind.quiz => provider.quizCursor,
        _BadgeKind.memory => provider.memoryBestScore,
        _BadgeKind.progress => provider.progressFor(progressKey!),
      };
    });
    return Text(switch (kind) {
      _BadgeKind.quiz => value > 0 ? 'Devam et' : 'Başla',
      _BadgeKind.memory => value > 0 ? 'Rekor $value' : 'Oyna',
      _BadgeKind.progress => value > 0 ? 'Puan $value' : 'Oyna',
    });
  }
}
