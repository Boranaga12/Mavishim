import 'package:mavishim/core/utils/cycle_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CycleInfo', () {
    test(
      'maps the day before a recorded start to the last day of the prior cycle',
      () {
        final info = CycleInfo(
          periodHistory: [DateTime(2026, 8, 1)],
          cycleLength: 28,
          targetDate: DateTime(2026, 7, 31),
        );

        expect(info.currentCycleDay, 28);
        expect(info.nextPeriodDate, DateTime(2026, 8, 1));
        expect(info.daysUntilNextPeriod, 1);
      },
    );

    test('uses the closest historical start for historical dates', () {
      final info = CycleInfo(
        periodHistory: [DateTime(2026, 8, 1), DateTime(2026, 7, 4)],
        cycleLength: 28,
        targetDate: DateTime(2026, 7, 5),
      );

      expect(info.currentCycleDay, 2);
      expect(info.currentPhase, CyclePhase.period);
    });

    test(
      'future forecast days are never marked late, but today can be late',
      () {
        final expectedDay = CycleInfo(
          periodHistory: [DateTime(2026, 8, 1)],
          cycleLength: 28,
          targetDate: DateTime(2026, 8, 29),
        );
        final lateDay = CycleInfo(
          periodHistory: [DateTime(2026, 8, 1)],
          cycleLength: 28,
          targetDate: DateTime(2026, 8, 30),
          referenceDate: DateTime(2026, 8, 30),
        );

        expect(expectedDay.isLate, isFalse);
        expect(expectedDay.daysUntilNextPeriod, 0);
        expect(lateDay.daysLate, 1);
        expect(lateDay.currentPhase, CyclePhase.late);

        final futureForecast = CycleInfo(
          periodHistory: [DateTime(2026, 8, 1)],
          cycleLength: 28,
          targetDate: DateTime(2026, 9, 5),
          referenceDate: DateTime(2026, 8, 20),
        );
        expect(futureForecast.isLate, isFalse);
      },
    );
  });
}
