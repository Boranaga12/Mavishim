enum CyclePhase { period, follicular, ovulation, luteal, late, noData }

enum CycleRhythm {
  insufficientData,
  regular,
  longerThanUsual,
  moreFrequent,
  variable,
}

class CyclePattern {
  final CycleRhythm rhythm;
  final int? averageLength;
  final int? shortestLength;
  final int? longestLength;
  final int confidence;
  final List<String> insights;

  const CyclePattern({
    required this.rhythm,
    required this.averageLength,
    required this.shortestLength,
    required this.longestLength,
    required this.confidence,
    required this.insights,
  });

  String get rhythmLabel => switch (rhythm) {
    CycleRhythm.insufficientData =>
      'Biraz daha işaretleyelim aşkım, seni daha iyi tanıyayım',
    CycleRhythm.regular => 'Ritmin gayet düzenli görünüyor Elifim',
    CycleRhythm.longerThanUsual =>
      'Bu aralar döngün biraz daha uzun gidiyor aşkım',
    CycleRhythm.moreFrequent =>
      'Bu aralar döngün biraz daha sık geliyor olabilir birtanem',
    CycleRhythm.variable =>
      'Tarihler biraz değişken gidiyor, birlikte takipteyiz ömrümm',
  };

  factory CyclePattern.fromHistory(
    List<DateTime> history, {
    required int fallbackLength,
  }) {
    final ordered =
        history
            .map((date) => DateTime(date.year, date.month, date.day))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));
    final intervals = <int>[];
    for (var index = 0; index < ordered.length - 1; index++) {
      final days = ordered[index].difference(ordered[index + 1]).inDays;
      if (days >= 15 && days <= 60) intervals.add(days);
    }
    if (intervals.length < 2) {
      return const CyclePattern(
        rhythm: CycleRhythm.insufficientData,
        averageLength: null,
        shortestLength: null,
        longestLength: null,
        confidence: 25,
        insights: [
          'Birkaç başlangıç gününü daha işaretle aşkım; seni daha iyi takip edeyim.',
        ],
      );
    }

    final average = (intervals.reduce((a, b) => a + b) / intervals.length)
        .round();
    final shortest = intervals.reduce((a, b) => a < b ? a : b);
    final longest = intervals.reduce((a, b) => a > b ? a : b);
    final spread = longest - shortest;
    final rhythm = spread >= 8
        ? CycleRhythm.variable
        : average >= fallbackLength + 6
        ? CycleRhythm.longerThanUsual
        : average <= fallbackLength - 4
        ? CycleRhythm.moreFrequent
        : CycleRhythm.regular;
    final confidence = (intervals.length * 18 + (24 - spread * 2))
        .clamp(35, 92)
        .toInt();
    final insights = <String>[
      'Elifim, son ${intervals.length} döngünde ortalaman $average gün; $shortest–$longest gün arasında değişmiş.',
      switch (rhythm) {
        CycleRhythm.regular =>
          'Tarihler birbirine yakın aşkım, bu yüzden tahminimiz daha netleşiyor.',
        CycleRhythm.longerThanUsual =>
          'Bu aralar aralıklar biraz uzun görünüyor birtanem; tek güne takılma, aralığa beraber bakalım.',
        CycleRhythm.moreFrequent =>
          'Bu aralar aralıklar biraz kısa görünüyor aşkım; başlangıç günlerini işaretledikçe seni daha iyi takip ederim.',
        CycleRhythm.variable =>
          'Tarihler biraz değişmiş Elifim. Uyku, stres ve günlük hayat etkileyebilir; sen işaretle, ben buradayım.',
        CycleRhythm.insufficientData => '',
      },
    ];
    if (rhythm == CycleRhythm.longerThanUsual) {
      insights.add(
        'Seçili hedefe göre yaklaşık ${average - fallbackLength} gün daha uzun bir ritim görülüyor; bu durum ardışık kayıtlarda sürerse kişisel ortalama ayarını güncellemek faydalı olabilir.',
      );
    } else if (rhythm == CycleRhythm.moreFrequent) {
      insights.add(
        'Seçili hedefe göre yaklaşık ${fallbackLength - average} gün daha kısa aralıklar görülüyor; yeni başlangıç kayıtları bu eğilimi doğrularsa tahmin buna uyarlanır.',
      );
    } else if (rhythm == CycleRhythm.variable) {
      insights.add(
        'En kısa ve en uzun kayıt arasında $spread gün fark var. Tek güne odaklanmak yerine geniş tahmin penceresini takip etmek daha anlamlıdır.',
      );
    }
    return CyclePattern(
      rhythm: rhythm,
      averageLength: average,
      shortestLength: shortest,
      longestLength: longest,
      confidence: confidence,
      insights: insights,
    );
  }
}

class CycleInfo {
  final DateTime? lastPeriodDate;
  final List<DateTime> periodHistory;
  final int cycleLength;
  final int periodDuration;
  final DateTime targetDate;
  final DateTime referenceDate;

  CycleInfo({
    this.lastPeriodDate,
    this.periodHistory = const [],
    this.cycleLength = 28,
    this.periodDuration = 5,
    DateTime? targetDate,
    DateTime? referenceDate,
  }) : targetDate = targetDate ?? DateTime.now(),
       referenceDate = referenceDate ?? DateTime.now();

  bool get hasData => periodHistory.isNotEmpty || lastPeriodDate != null;

  List<DateTime> get _history {
    final uniqueValues = periodHistory.map(_dateOnly).toSet();
    if (lastPeriodDate != null) uniqueValues.add(_dateOnly(lastPeriodDate!));
    final values = uniqueValues.toList();
    values.sort();
    return values;
  }

  DateTime get _target => _dateOnly(targetDate);
  DateTime get _reference => _dateOnly(referenceDate);

  DateTime get _anchorDate {
    final history = _history;
    if (history.isEmpty) return _target;
    final previous = history.where((date) => !date.isAfter(_target)).toList();
    return previous.isNotEmpty ? previous.last : history.first;
  }

  DateTime? get _nextRecordedStart {
    final later = _history.where((date) => date.isAfter(_anchorDate)).toList();
    return later.isEmpty ? null : later.first;
  }

  int get activeCycleLength {
    final next = _nextRecordedStart;
    if (next == null) return cycleLength;
    final measured = next.difference(_anchorDate).inDays;
    return measured >= 15 && measured <= 60 ? measured : cycleLength;
  }

  int get daysSinceLastPeriod {
    if (!hasData) return 0;
    return _target.difference(_anchorDate).inDays;
  }

  int get currentCycleDay {
    if (!hasData) return 1;
    final length = activeCycleLength;
    if (daysSinceLastPeriod >= 0) return daysSinceLastPeriod + 1;
    final normalizedModulo = ((daysSinceLastPeriod % length) + length) % length;
    return normalizedModulo + 1;
  }

  bool get isLate {
    if (!hasData) return false;
    // A future calendar day is a forecast, never a delay. Delays are shown
    // only for today after the expected start date has passed.
    return _target == _reference && _target.isAfter(nextPeriodDate);
  }

  int get daysLate {
    if (!isLate || !hasData) return 0;
    return _target.difference(nextPeriodDate).inDays;
  }

  int get daysUntilNextPeriod {
    if (!hasData || isLate) return 0;
    return nextPeriodDate
        .difference(_target)
        .inDays
        .clamp(0, activeCycleLength)
        .toInt();
  }

  int get predictionWindowDays => switch (periodHistory.length) {
    < 2 => 4,
    < 4 => 3,
    _ =>
      CyclePattern.fromHistory(
                periodHistory,
                fallbackLength: cycleLength,
              ).rhythm ==
              CycleRhythm.regular
          ? 1
          : 3,
  };

  DateTime get predictionWindowStart =>
      nextPeriodDate.subtract(Duration(days: predictionWindowDays));
  DateTime get predictionWindowEnd =>
      nextPeriodDate.add(Duration(days: predictionWindowDays));

  DateTime get nextPeriodDate {
    if (_target.isBefore(_anchorDate)) return _anchorDate;
    return _nextRecordedStart ??
        _anchorDate.add(Duration(days: activeCycleLength));
  }

  int get estimatedOvulationDay => (activeCycleLength - 14)
      .clamp(periodDuration + 1, activeCycleLength)
      .toInt();

  CyclePhase get currentPhase {
    if (!hasData) return CyclePhase.noData;
    if (isLate) return CyclePhase.late;
    final day = currentCycleDay;
    if (day <= periodDuration) {
      return CyclePhase.period;
    } else if (day < estimatedOvulationDay - 2) {
      return CyclePhase.follicular;
    } else if (day <= estimatedOvulationDay + 2) {
      return CyclePhase.ovulation;
    } else {
      return CyclePhase.luteal;
    }
  }

  String get phaseName {
    if (!hasData) return 'Elifimin ilk kaydı bekleniyor';
    switch (currentPhase) {
      case CyclePhase.period:
        return 'Elifimin dinlenme günleri';
      case CyclePhase.follicular:
        return 'Aşkımın enerji günleri';
      case CyclePhase.ovulation:
        return 'Elifimin ışıldadığı günler';
      case CyclePhase.luteal:
        return 'Aşkımın sakin günleri';
      case CyclePhase.late:
        return 'Aşkım, $daysLate gün gecikme var';
      case CyclePhase.noData:
        return 'Elifimin ilk kaydı bekleniyor';
    }
  }

  // Beklenen Ruh Halleri
  List<String> get expectedMoods {
    if (!hasData) return ['Kayıt Bekleniyor 🌸'];
    switch (currentPhase) {
      case CyclePhase.period:
        return ['Duygusal 🥺', 'Hassas 🌸', 'Yorgun 😴', 'Sarılma İsteği 🫂'];
      case CyclePhase.follicular:
        return ['Enerjik ⚡', 'Mutlu 😃', 'Motivasyonlu 💪', 'Tutkulu 🔥'];
      case CyclePhase.ovulation:
        return ['Yüksek Libido 🔥', 'Işıltılı 🌟', 'Romantik 🥰', 'Arzulu 💖'];
      case CyclePhase.luteal:
        return ['Sakin 🌙', 'Tatlı İsteği 🍫', 'Duygusal 🥺', 'Hassas 🌸'];
      case CyclePhase.late:
        return ['Endişeli 💭', 'Hassas 🌸', 'Sakinlik İhtiyacı 🌿'];
      case CyclePhase.noData:
        return ['Kayıt Yok'];
    }
  }

  // Beklenen Belirtiler & Cinsel Yaşam
  List<String> get expectedSymptoms {
    if (!hasData) return [];
    switch (currentPhase) {
      case CyclePhase.period:
        return ['Kramp 💥', 'Bel Ağrısı 🦴', 'Hafif Yorgunluk 🥱'];
      case CyclePhase.follicular:
        return [
          'Cilt Canlılığı ✨',
          'Yüksek Fiziksel Enerji ⚡',
          'Libido Artışı 🔥',
        ];
      case CyclePhase.ovulation:
        return [
          'Yüksek Libido / Arzu 🔥',
          'Hafif Kasık Ağrısı 💧',
          'Parlak Cilt 🌟',
        ];
      case CyclePhase.luteal:
        return ['Şişkinlik 🎈', 'Göğüs Hassasiyeti 🌸', 'Hafif Baş Ağrısı 🤕'];
      case CyclePhase.late:
        return ['Hafif Şişkinlik 💧', 'Hassasiyet 🌸'];
      case CyclePhase.noData:
        return [];
    }
  }

  // Unified Care & Relationship Tip (Her Tip + Boyfriend Tip merged!)
  String get unifiedTip {
    if (!hasData) {
      return 'Hoş geldin Elifimmm 💗 Hadi takvime gir de ilk regl gününü işaretle aşkım; sonra seni birlikte takip ederiz.';
    }
    switch (currentPhase) {
      case CyclePhase.period:
        return 'Elifim, bugün kendine nazik davran aşkım. Sıcak çayını, battaniyeni hazırla; ben olsam sana sımsıkı sarılırdım. 🌸💗';
      case CyclePhase.follicular:
        return 'Aşkım enerjin yükseliyor gibi, bugün içinden ne geliyorsa yap. İstersen sana tatlı bir randevu da planlayayım Elifim. ✨';
      case CyclePhase.ovulation:
        return 'Elifim bugün ışıl ışıl olabilirsin; zaten benim için her gün çok güzelsin aşkım. Kendini nasıl iyi hissediyorsan öyle davran. 🌟';
      case CyclePhase.luteal:
        return 'Ömrümm, vücudun biraz dinlenmek istiyor olabilir. Sana çay, tatlı, film gecesi ve kocaman sarılma borçluyum. 🌙';
      case CyclePhase.late:
        return 'Birtanem, hafif gecikmeler olabilir; kendini üzme olur mu? Rahatla, ben yanındayım ve seni çok seviyorum. 🌿';
      case CyclePhase.noData:
        return 'Aşkım, takvimden bir gün seç de ona birlikte bakalım.';
    }
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
