import 'package:flutter/material.dart';

import '../providers/game_provider.dart';

Future<void> showWheelManagementSheet(
  BuildContext context,
  GameProvider provider,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _WheelManagementSheet(provider: provider),
  );
}

Future<void> showCreateWheelDialog(
  BuildContext context,
  GameProvider provider,
) {
  return showDialog<void>(
    context: context,
    builder: (_) => _CreateWheelDialog(provider: provider),
  );
}

class _WheelManagementSheet extends StatefulWidget {
  final GameProvider provider;

  const _WheelManagementSheet({required this.provider});

  @override
  State<_WheelManagementSheet> createState() => _WheelManagementSheetState();
}

class _WheelManagementSheetState extends State<_WheelManagementSheet> {
  final _newOptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.provider.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.provider.removeListener(_refresh);
    _newOptionController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final activeWheel = provider.activeWheel;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  activeWheel.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_note),
                tooltip: 'Çark ismini değiştir',
                onPressed: () => _showTextEditDialog(
                  context,
                  title: 'Çark ismini değiştir',
                  initialValue: activeWheel.title,
                  hintText: 'Yeni çark ismi',
                  onSave: provider.renameActiveWheel,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                tooltip: 'Bu çarkı sil',
                onPressed: () => _deleteWheel(context, provider),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Kapat',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: activeWheel.options.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final option = activeWheel.options[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(option),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Seçeneği düzenle',
                        onPressed: () => _showTextEditDialog(
                          context,
                          title: 'Seçeneği düzenle',
                          initialValue: option,
                          hintText: 'Seçenek metni',
                          onSave: (value) =>
                              provider.editOptionInActiveWheel(index, value),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        tooltip: 'Seçeneği sil',
                        onPressed: () =>
                            _deleteOption(context, provider, index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newOptionController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: 'Yeni seçenek',
                    labelText: 'Seçenek ekle',
                  ),
                  onSubmitted: (_) => _addOption(provider),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => _addOption(provider),
                child: const Text('Ekle'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addOption(GameProvider provider) {
    final value = _newOptionController.text.trim();
    if (value.isEmpty) return;
    provider.addOptionToActiveWheel(value);
    _newOptionController.clear();
  }

  void _deleteOption(BuildContext context, GameProvider provider, int index) {
    if (provider.activeWheel.options.length <= 2) {
      _showMessage(context, 'Çarkta en az iki seçenek bulunmalı.');
      return;
    }
    provider.removeOptionFromActiveWheel(index);
  }

  void _deleteWheel(BuildContext context, GameProvider provider) {
    if (provider.wheels.length <= 1) {
      _showMessage(context, 'En az bir çark bulunmalı.');
      return;
    }
    provider.deleteActiveWheel();
    Navigator.pop(context);
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CreateWheelDialog extends StatefulWidget {
  final GameProvider provider;

  const _CreateWheelDialog({required this.provider});

  @override
  State<_CreateWheelDialog> createState() => _CreateWheelDialogState();
}

class _CreateWheelDialogState extends State<_CreateWheelDialog> {
  final _titleController = TextEditingController();
  final _firstOptionController = TextEditingController();
  final _secondOptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _firstOptionController.dispose();
    _secondOptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Özel çark oluştur'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Çark başlığı'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _firstOptionController,
              decoration: const InputDecoration(labelText: '1. seçenek'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _secondOptionController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: '2. seçenek'),
              onSubmitted: (_) => _create(context),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        FilledButton(
          onPressed: () => _create(context),
          child: const Text('Oluştur'),
        ),
      ],
    );
  }

  void _create(BuildContext context) {
    final title = _titleController.text.trim();
    final first = _firstOptionController.text.trim();
    final second = _secondOptionController.text.trim();
    if (title.isEmpty || first.isEmpty || second.isEmpty) return;
    widget.provider.createCustomWheel(title, [first, second]);
    Navigator.pop(context);
  }
}

Future<void> _showTextEditDialog(
  BuildContext context, {
  required String title,
  required String initialValue,
  required String hintText,
  required ValueChanged<String> onSave,
}) async {
  final controller = TextEditingController(text: initialValue);
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(hintText: hintText),
        textInputAction: TextInputAction.done,
        onSubmitted: (value) {
          final trimmed = value.trim();
          if (trimmed.isEmpty) return;
          onSave(trimmed);
          Navigator.pop(context);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        FilledButton(
          onPressed: () {
            final value = controller.text.trim();
            if (value.isEmpty) return;
            onSave(value);
            Navigator.pop(context);
          },
          child: const Text('Kaydet'),
        ),
      ],
    ),
  );
  controller.dispose();
}
