import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/cycle_phase_theme.dart';
import '../../models/daily_log.dart';
import '../../providers/cycle_provider.dart';
import '../../widgets/cycle_dial.dart';
import '../../widgets/daily_log_picker.dart';
import '../../widgets/glass_card.dart';

class CycleDashboard extends StatelessWidget {
  const CycleDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CycleProvider>();
    final today = DateTime.now();
    final info = provider.cycleInfo;
    final log = provider.getLogForDate(today);
    final tip = info.unifiedTip;

    return Scaffold(
      body: DecoratedBox(
        decoration: AppTheme.pageBackground(context),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _Header(
                emoji: log.dailyEmoji,
                onEmojiPressed: () =>
                    DailyLogPicker.showEmoji(context, provider, today),
              ),
              const SizedBox(height: 16),
              Semantics(
                label: info.isLate
                    ? 'Döngü ${info.daysLate} gün gecikti'
                    : 'Döngünün ${info.currentCycleDay}. günü',
                child: CycleDial(cycleInfo: info),
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: info.phaseColor.withValues(alpha: 0.15),
                      foregroundColor: info.phaseColor,
                      child: Icon(
                        info.isLate ? Icons.warning_amber_rounded : Icons.spa,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info.phaseName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tip,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cards = [
                    _LogCard(
                      title: 'Günlük Mod',
                      value: log.mood ?? 'Seçim yap',
                      icon: Icons.sentiment_satisfied_alt,
                      color: AppTheme.primaryPink,
                      onTap: () =>
                          DailyLogPicker.showMood(context, provider, today),
                    ),
                    _LogCard(
                      title: 'Günlük İstek',
                      value: _intimacyLabel(log),
                      icon: Icons.local_fire_department,
                      color: Colors.deepOrange,
                      onTap: () =>
                          DailyLogPicker.showIntimacy(context, provider, today),
                    ),
                  ];
                  if (constraints.maxWidth < 520) {
                    return Column(
                      children: [
                        cards.first,
                        const SizedBox(height: 12),
                        cards.last,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cards.first),
                      const SizedBox(width: 12),
                      Expanded(child: cards.last),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              _CycleInsightsCard(provider: provider),
              const SizedBox(height: 12),
              GlassCard(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.78),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.lutealColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Döngü ve yumurtlama tarihleri tahmindir. Tıbbi teşhis veya gebelikten korunma amacıyla kullanılamaz.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _intimacyLabel(DailyLog log) {
    if (log.intimacy == null) return 'Seçim yap';
    return log.favPosition == null
        ? log.intimacy!
        : '${log.intimacy} • ${log.favPosition}';
  }
}

class _Header extends StatelessWidget {
  final String? emoji;
  final VoidCallback onEmojiPressed;

  const _Header({required this.emoji, required this.onEmojiPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            'assets/branding/mavishim_icon.png',
            width: 48,
            height: 48,
            cacheWidth: 144,
            cacheHeight: 144,
            fit: BoxFit.cover,
            semanticLabel: 'Mavishim logosu',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hoş geldin', style: Theme.of(context).textTheme.bodyMedium),
              Text(
                'Mavishim',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
        // The persistent theme control occupies the top-right corner.
        // Reserve its touch area so the daily emoji button remains usable.
        Padding(
          padding: const EdgeInsets.only(right: 56),
          child: IconButton.filledTonal(
            onPressed: onEmojiPressed,
            tooltip: 'Günün emojisini seç',
            icon: Text(emoji ?? '✨', style: const TextStyle(fontSize: 22)),
          ),
        ),
      ],
    );
  }
}

class _CycleInsightsCard extends StatelessWidget {
  final CycleProvider provider;

  const _CycleInsightsCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final pattern = provider.cyclePattern;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights, color: AppTheme.lutealColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kişisel Döngü Analizi',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Chip(label: Text('%${pattern.confidence} güven')),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            pattern.rhythmLabel,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ...provider.professionalInsights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('• $insight'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _LogCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.14),
            foregroundColor: color,
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(value, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
