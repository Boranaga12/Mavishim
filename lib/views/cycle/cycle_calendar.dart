import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/cycle_phase_theme.dart';
import '../../providers/cycle_provider.dart';
import '../../widgets/daily_log_picker.dart';
import '../../widgets/glass_card.dart';

class CycleCalendarView extends StatefulWidget {
  const CycleCalendarView({super.key});

  @override
  State<CycleCalendarView> createState() => _CycleCalendarViewState();
}

class _CycleCalendarViewState extends State<CycleCalendarView> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CycleProvider>();
    final selectedLog = provider.getLogForDate(_selectedDay);
    final info = provider.infoForDate(_selectedDay);
    final isStart = provider.isPeriodStartDate(_selectedDay);
    final tip = info.unifiedTip;

    return Scaffold(
      body: DecoratedBox(
        decoration: AppTheme.pageBackground(context),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Döngü Takvimi',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 56),
                    child: TextButton.icon(
                      onPressed: _resetToToday,
                      icon: const Icon(Icons.today),
                      label: const Text('Bugün'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GlassCard(
                padding: const EdgeInsets.all(8),
                child: TableCalendar<void>(
                  locale: 'tr_TR',
                  firstDay: DateTime(DateTime.now().year - 5),
                  lastDay: DateTime(DateTime.now().year + 3, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  availableGestures: AvailableGestures.horizontalSwipe,
                  rowHeight: 48,
                  daysOfWeekHeight: 34,
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      semanticLabel: 'Önceki ay',
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      semanticLabel: 'Sonraki ay',
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, _) =>
                        _CalendarDay(day: day, provider: provider),
                    todayBuilder: (context, day, _) => _CalendarDay(
                      day: day,
                      provider: provider,
                      isToday: true,
                    ),
                    selectedBuilder: (context, day, _) => _CalendarDay(
                      day: day,
                      provider: provider,
                      isSelected: true,
                    ),
                    outsideBuilder: (context, day, _) => _CalendarDay(
                      day: day,
                      provider: provider,
                      isOutside: true,
                    ),
                  ),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                  },
                  onPageChanged: (focused) => _focusedDay = focused,
                ),
              ),
              const SizedBox(height: 8),
              const _CalendarLegend(),
              const SizedBox(height: 12),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat(
                                  'd MMMM yyyy, EEEE',
                                  'tr_TR',
                                ).format(_selectedDay),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                info.hasData
                                    ? '${info.currentCycleDay}. gün • ${info.phaseName}'
                                    : 'Henüz kayıt yok',
                                style: TextStyle(
                                  color: info.phaseColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (info.hasData) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Tahmin penceresi: ${DateFormat('d MMM', 'tr_TR').format(info.predictionWindowStart)} – ${DateFormat('d MMM', 'tr_TR').format(info.predictionWindowEnd)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () => _togglePeriod(provider, isStart),
                          style: FilledButton.styleFrom(
                            backgroundColor: isStart
                                ? Colors.red.shade600
                                : AppTheme.primaryPink,
                          ),
                          icon: Icon(
                            isStart ? Icons.delete_outline : Icons.add,
                          ),
                          label: Text(isStart ? 'Sil' : 'Regl Ekle'),
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    if (_isEditableDate(_selectedDay)) ...[
                      _RecordTile(
                        icon: Icons.sentiment_satisfied_alt,
                        title: 'Günlük Mod',
                        value: selectedLog.mood ?? 'Ekle',
                        color: AppTheme.primaryPink,
                        onTap: () => DailyLogPicker.showMood(
                          context,
                          provider,
                          _selectedDay,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _RecordTile(
                        icon: Icons.local_fire_department,
                        title: 'Günlük İstek',
                        value: selectedLog.intimacy ?? 'Ekle',
                        color: Colors.deepOrange,
                        onTap: () => DailyLogPicker.showIntimacy(
                          context,
                          provider,
                          _selectedDay,
                        ),
                      ),
                      const Divider(height: 28),
                    ] else if (!selectedLog.isEmpty) ...[
                      if (selectedLog.mood != null)
                        Text('Günlük mod: ${selectedLog.mood}'),
                      if (selectedLog.intimacy != null)
                        Text('Günlük istek: ${selectedLog.intimacy}'),
                      const Divider(height: 28),
                    ],
                    Text(
                      'Beklenen ruh hali',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: info.expectedMoods
                          .map(
                            (item) => Chip(
                              label: Text(item),
                              avatar: const Icon(Icons.mood, size: 18),
                            ),
                          )
                          .toList(),
                    ),
                    if (info.expectedSymptoms.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Beklenen belirtiler',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: info.expectedSymptoms
                            .map((item) => Chip(label: Text(item)))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: info.phaseColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(tip),
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

  void _resetToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDay = now;
      _focusedDay = now;
    });
  }

  bool _isEditableDate(DateTime date) {
    final today = DateUtils.dateOnly(DateTime.now());
    final selected = DateUtils.dateOnly(date);
    return selected == today ||
        selected == today.subtract(const Duration(days: 1));
  }

  Future<void> _togglePeriod(CycleProvider provider, bool isStart) async {
    final messenger = ScaffoldMessenger.of(context);
    if (isStart) {
      final removed = await provider.removePeriodDate(_selectedDay);
      if (!mounted || !removed) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Regl kaydı silindi.')),
      );
      return;
    }
    final error = await provider.addPeriodDate(_selectedDay);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(error ?? 'Regl başlangıç tarihi kaydedildi.'),
        backgroundColor: error == null ? null : Colors.red.shade700,
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final DateTime day;
  final CycleProvider provider;
  final bool isSelected;
  final bool isToday;
  final bool isOutside;

  const _CalendarDay({
    required this.day,
    required this.provider,
    this.isSelected = false,
    this.isToday = false,
    this.isOutside = false,
  });

  @override
  Widget build(BuildContext context) {
    final isStart = provider.isPeriodStartDate(day);
    final isRecordedPeriod = provider.isRecordedPeriodDay(day);
    final isPredictedPeriod = provider.isNextPredictedPeriodDay(day);
    final isPredictionWindow = provider.isPredictionWindowDay(day);
    final isOvulation = provider.isNextPredictedOvulationDay(day);
    final emoji = provider.getLogForDate(day).dailyEmoji;
    final background = isStart
        ? AppTheme.periodColor
        : isRecordedPeriod
        ? AppTheme.periodColor.withValues(alpha: 0.45)
        : isPredictedPeriod
        ? AppTheme.periodColor.withValues(alpha: 0.14)
        : isOvulation
        ? AppTheme.ovulationColor.withValues(alpha: 0.18)
        : isPredictionWindow
        ? AppTheme.periodColor.withValues(alpha: 0.07)
        : Colors.transparent;
    final foreground = isStart
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    final labels = <String>[
      DateFormat('d MMMM', 'tr_TR').format(day),
      if (isStart) 'regl başlangıcı',
      if (isRecordedPeriod && !isStart) 'regl günü',
      if (isPredictedPeriod) 'tahmini regl günü',
      if (isPredictionWindow && !isPredictedPeriod) 'regl tahmin penceresi',
      if (isOvulation) 'tahmini yumurtlama günü',
      if (emoji != null) 'günün emojisi $emoji',
    ];

    return Semantics(
      button: true,
      selected: isSelected,
      label: labels.join(', '),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? AppTheme.deepPurple
                : isToday
                ? AppTheme.primaryPink
                : isPredictionWindow
                ? AppTheme.periodColor.withValues(alpha: 0.45)
                : Colors.transparent,
            width: isSelected ? 2.5 : (isPredictionWindow ? 1 : 1.5),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${day.day}',
                style: TextStyle(
                  color: foreground.withValues(alpha: isOutside ? 0.35 : 1),
                  fontWeight: isSelected || isStart
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              if (emoji != null)
                Text(emoji, style: const TextStyle(fontSize: 9)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 6,
      children: const [
        _LegendItem(color: AppTheme.periodColor, label: 'Kayıtlı'),
        _LegendItem(color: Color(0x38E83E5B), label: 'Tahmini regl'),
        _LegendItem(color: Color(0x12E83E5B), label: 'Tahmin penceresi'),
        _LegendItem(color: Color(0x309A6500), label: 'Yumurtlama'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: const SizedBox.square(dimension: 12),
        ),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _RecordTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _RecordTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.14),
        foregroundColor: color,
        child: Icon(icon),
      ),
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
