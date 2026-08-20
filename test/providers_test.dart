import 'package:mavishim/models/daily_log.dart';
import 'package:mavishim/providers/cycle_provider.dart';
import 'package:mavishim/providers/game_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_app_repository.dart';

void main() {
  test(
    'cycle provider persists records and rolls back failed writes',
    () async {
      final repository = FakeAppRepository();
      final provider = CycleProvider(
        repository,
        repository.snapshot,
        now: () => DateTime(2026, 8, 19),
      );

      expect(await provider.addPeriodDate(DateTime(2026, 8, 1)), isNull);
      expect(repository.snapshot.periodHistory, [DateTime(2026, 8, 1)]);

      repository.shouldFail = true;
      final saved = await provider.saveDailyLog(
        DailyLog(dateKey: '2026-08-19', mood: 'Mutlu 😃'),
      );
      expect(saved, isFalse);
      expect(provider.getLogForDate(DateTime(2026, 8, 19)).mood, isNull);
      expect(provider.errorMessage, isNotNull);
    },
  );

  test('game provider persists wheels and clamps quiz score', () async {
    final repository = FakeAppRepository();
    final provider = GameProvider(repository, repository.snapshot);

    await provider.createCustomWheel('Randevu', ['Sinema', 'Piknik']);
    await provider.updateQuizScore(140);

    expect(repository.snapshot.wheels.last.title, 'Randevu');
    expect(provider.quizBestScore, 100);
  });
}
