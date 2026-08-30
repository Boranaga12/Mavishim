import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/audio/app_audio.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/game_provider.dart';
import '../../widgets/glass_card.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  double? _cycleLength;
  double? _periodDuration;

  @override
  Widget build(BuildContext context) {
    final cycleLength = context.select<CycleProvider, int>(
      (value) => value.cycleLength,
    );
    final periodDuration = context.select<CycleProvider, int>(
      (value) => value.periodDuration,
    );
    final isSaving = context.select<CycleProvider, bool>(
      (value) => value.isSaving,
    );
    final soundVolume = context.select<GameProvider, int>(
      (value) => value.soundVolumePercent,
    );
    _cycleLength ??= cycleLength.toDouble();
    _periodDuration ??= periodDuration.toDouble();

    return Scaffold(
      body: DecoratedBox(
        decoration: AppTheme.pageBackground(context),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Ayarlar', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sesler',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text('Ses seviyesi: %$soundVolume'),
                    Slider(
                      value: soundVolume.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: '%$soundVolume',
                      onChanged: (value) => context
                          .read<GameProvider>()
                          .setSoundVolume(value / 100),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () => AppAudio.instance.play(AppSound.uiTap),
                        icon: const Icon(Icons.volume_up_outlined),
                        label: const Text('Ses Örneğini Dinle'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Döngü Ayarları',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Text('Ortalama döngü: ${_cycleLength!.round()} gün'),
                    Slider(
                      value: _cycleLength!,
                      min: 15,
                      max: 60,
                      divisions: 45,
                      label: '${_cycleLength!.round()} gün',
                      onChanged: (value) =>
                          setState(() => _cycleLength = value),
                    ),
                    Text('Regl süresi: ${_periodDuration!.round()} gün'),
                    Slider(
                      value: _periodDuration!,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: '${_periodDuration!.round()} gün',
                      onChanged: (value) =>
                          setState(() => _periodDuration = value),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          final saved = await context
                              .read<CycleProvider>()
                              .updateCycleSettings(
                                cycleLength: _cycleLength!.round(),
                                periodDuration: _periodDuration!.round(),
                              );
                          if (!context.mounted || !saved) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Döngü ayarları kaydedildi.'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Ayarları Kaydet'),
                      ),
                    ),
                  ],
                ),
              ),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gizlilik',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Döngü ve günlük kayıtları cihazda şifreli tutulur. Tahminler yalnızca bilgilendirme amaçlıdır; tıbbi teşhis veya gebelikten korunma yöntemi değildir.',
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: isSaving ? null : _confirmDeleteAllData,
                        icon: const Icon(Icons.delete_forever_outlined),
                        label: Text(
                          isSaving ? 'Siliniyor…' : 'Tüm Verilerimi Sil',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Mavishim 1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tüm veriler silinsin mi?'),
        content: const Text(
          'Döngü geçmişi, günlük kayıtlar, oyun skorları ve özel çarklar kalıcı olarak silinecek. Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Kalıcı Olarak Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final deleted = await context.read<CycleProvider>().clearAllData();
    if (!mounted || !deleted) return;
    context.read<GameProvider>().resetAfterDataDeletion();
    setState(() {
      _cycleLength = 28;
      _periodDuration = 5;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cihazdaki tüm Mavishim verileri silindi.')),
    );
  }
}
