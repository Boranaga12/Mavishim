import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_theme.dart';
import '../models/daily_log.dart';
import '../providers/cycle_provider.dart';

abstract final class DailyLogPicker {
  static const emojis = [
    '💖',
    '🔥',
    '🌸',
    '👑',
    '✨',
    '🌊',
    '😴',
    '🥳',
    '🌧️',
    '⚡',
    '🍕',
    '🎬',
    '🍬',
    '🐾',
  ];
  static const moods = [
    'Mutlu 😃',
    'Romantik 🥰',
    'Duygusal 🥺',
    'Enerjik ⚡',
    'Gergin 🌩️',
    'Yorgun 😴',
    'Sevecen 💖',
    'Tutkulu 🔥',
    'Neşeli 🥳',
    'Sakin 🌙',
    'Stresli 🌀',
    'Heyecanlı 🤩',
    'Uykulu 🛌',
  ];
  static const intimacyOptions = [
    'İsteksiz / Düşük 💤',
    'Normal İstek 🌸',
    'Yüksek Libido 🔥',
    'Tutkulu / Ateşli ❤️‍🔥',
    'Özel & Romantik An 💞',
    'Yakınlık Yaşandı 💖',
  ];
  static const positionOptions = [
    'Misyoner',
    'Arkadan',
    'Üstte',
    'Ters üstte',
    'Kaşık pozisyonu',
    'Kucakta sarılmalı',
    'Ayakta',
    '69 pozisyonu',
    'Lotus',
    'Oral yakınlık',
  ];

  static Future<void> showEmoji(
    BuildContext context,
    CycleProvider provider,
    DateTime date,
  ) async {
    final current = provider.getLogForDate(date);
    final controller = TextEditingController(text: current.dailyEmoji ?? '');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bugün nasıl bir gündü aşkım?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 12,
                inputFormatters: [_EmojiOnlyFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Bir emoji bırak bana Elifim',
                  hintText: 'Örn. 💙✨🌙',
                  helperText: 'Bunu görünce seni hatırlayayım aşkım.',
                ),
                onSubmitted: (_) => _saveKeyboardEmoji(
                  sheetContext,
                  provider,
                  current,
                  controller.text,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => _saveKeyboardEmoji(
                    sheetContext,
                    provider,
                    current,
                    controller.text,
                  ),
                  child: const Text('Bana Kaydet'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Kalbinden seç birtanem',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: emojis
                    .map(
                      (emoji) => Semantics(
                        button: true,
                        selected: current.dailyEmoji == emoji,
                        label: 'Emoji $emoji',
                        child: ChoiceChip(
                          label: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          selected: current.dailyEmoji == emoji,
                          onSelected: (_) async {
                            await provider.saveDailyLog(
                              current.copyWith(dailyEmoji: emoji),
                            );
                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
              if (current.dailyEmoji != null)
                TextButton.icon(
                  onPressed: () async {
                    await provider.saveDailyLog(
                      current.copyWith(dailyEmoji: null),
                    );
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Emojiyi Kaldır'),
                ),
            ],
          ),
        ),
      ),
    );
    // Let the bottom sheet finish its reverse animation before releasing the
    // controller; the TextField can still paint for a frame after pop().
    await Future<void>.delayed(const Duration(milliseconds: 400));
    controller.dispose();
  }

  static Future<void> _saveKeyboardEmoji(
    BuildContext context,
    CycleProvider provider,
    DailyLog current,
    String value,
  ) async {
    final emoji = _emojiOnly(value);
    if (emoji.isEmpty) return;
    await provider.saveDailyLog(current.copyWith(dailyEmoji: emoji));
    if (context.mounted) Navigator.pop(context);
  }

  static Future<void> showMood(
    BuildContext context,
    CycleProvider provider,
    DateTime date,
  ) async {
    final current = provider.getLogForDate(date);
    await _showChoiceSheet(
      context: context,
      title: 'Bugün nasıl hissediyorsun aşkım?',
      values: moods,
      selectedValue: current.mood,
      onSelected: (value) =>
          provider.saveDailyLog(current.copyWith(mood: value)),
      onClear: current.mood == null
          ? null
          : () => provider.saveDailyLog(current.copyWith(mood: null)),
    );
  }

  static Future<void> showIntimacy(
    BuildContext context,
    CycleProvider provider,
    DateTime date,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final current = provider.getLogForDate(date);
          final canSelectPosition =
              current.intimacy != null &&
              current.intimacy != intimacyOptions.first &&
              current.intimacy != intimacyOptions[1];
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                MediaQuery.viewInsetsOf(context).bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bugün ne hissediyorsun Elifim?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: intimacyOptions
                        .map(
                          (value) => ChoiceChip(
                            label: Text(value),
                            selected: current.intimacy == value,
                            selectedColor: Colors.deepOrange,
                            onSelected: (_) async {
                              final keepsPosition =
                                  value != intimacyOptions.first &&
                                  value != intimacyOptions[1];
                              await provider.saveDailyLog(
                                current.copyWith(
                                  intimacy: value,
                                  favPosition: keepsPosition
                                      ? current.favPosition
                                      : null,
                                ),
                              );
                              setModalState(() {});
                            },
                          ),
                        )
                        .toList(),
                  ),
                  if (canSelectPosition) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Tercih Edilen Pozisyon',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: positionOptions
                          .map(
                            (value) => ChoiceChip(
                              label: Text(value),
                              selected: current.favPosition == value,
                              onSelected: (_) async {
                                await provider.saveDailyLog(
                                  current.copyWith(favPosition: value),
                                );
                                setModalState(() {});
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (current.intimacy != null)
                        TextButton.icon(
                          onPressed: () async {
                            await provider.saveDailyLog(
                              current.copyWith(
                                intimacy: null,
                                favPosition: null,
                              ),
                            );
                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Kaydı Temizle'),
                        ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: const Text('Tamam Aşkım'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Future<void> _showChoiceSheet({
    required BuildContext context,
    required String title,
    required List<String> values,
    required String? selectedValue,
    required Future<bool> Function(String value) onSelected,
    required Future<bool> Function()? onClear,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: values
                    .map(
                      (value) => ChoiceChip(
                        label: Text(value),
                        selected: selectedValue == value,
                        selectedColor: AppTheme.primaryPink,
                        onSelected: (_) async {
                          await onSelected(value);
                          if (sheetContext.mounted) Navigator.pop(sheetContext);
                        },
                      ),
                    )
                    .toList(),
              ),
              if (onClear != null)
                TextButton.icon(
                  onPressed: () async {
                    await onClear();
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Kaydı Temizle'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmojiOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = _emojiOnly(newValue.text);
    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
  }
}

String _emojiOnly(String value) {
  final buffer = StringBuffer();
  for (final rune in value.runes) {
    final isEmoji =
        (rune >= 0x1F000 && rune <= 0x1FAFF) ||
        (rune >= 0x2600 && rune <= 0x27BF) ||
        rune == 0x200D ||
        rune == 0xFE0F ||
        (rune >= 0x1F1E6 && rune <= 0x1F1FF);
    if (isEmoji) buffer.writeCharCode(rune);
  }
  return buffer.toString();
}
