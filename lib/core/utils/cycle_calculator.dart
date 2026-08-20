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
    CycleRhythm.insufficientData => 'Kayıtlar çoğaldıkça tahmin netleşir',
    CycleRhythm.regular => 'Döngü ritmi düzenli görünüyor',
    CycleRhythm.longerThanUsual => 'Döngü ortalaması daha uzun seyrediyor',
    CycleRhythm.moreFrequent => 'Döngü daha sıklaşıyor olabilir',
    CycleRhythm.variable => 'Döngü aralıkları değişken görünüyor',
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
          'En az üç regl başlangıcı kaydedildiğinde kişisel ritim daha net hesaplanır.',
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
      'Son ${intervals.length} aralık: ortalama $average gün, $shortest–$longest gün aralığında.',
      switch (rhythm) {
        CycleRhythm.regular =>
          'Aralıklar birbirine yakın; tahmin penceresi daha güvenilir.',
        CycleRhythm.longerThanUsual =>
          'Kayıtlarda hedef uzunluktan daha uzun aralıklar baskın. Tek bir tarih yerine tahmin penceresini takip et.',
        CycleRhythm.moreFrequent =>
          'Kayıtlarda daha kısa aralıklar baskın. Yeni başlangıçları kaydetmek tahmini hızla iyileştirir.',
        CycleRhythm.variable =>
          'Aralık farkı yüksek. Uyku, stres, hastalık ve yaşam değişiklikleri döngüyü etkileyebilir; düzenli kayıt yararlı olur.',
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
    if (!hasData) return 'Kayıt Girilmedi';
    switch (currentPhase) {
      case CyclePhase.period:
        return 'Adet Dönemi';
      case CyclePhase.follicular:
        return 'Foliküler Faz (Yüksek Enerji)';
      case CyclePhase.ovulation:
        return 'Yumurtlama Dönemi (Yüksek Doğurganlık)';
      case CyclePhase.luteal:
        return 'Luteal Faz (Dinlenme)';
      case CyclePhase.late:
        return 'Regl Gecikmesi ($daysLate Gün)';
      case CyclePhase.noData:
        return 'Kayıt Girilmedi';
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
      return 'Takvimden ilk regl tarihini işaretleyerek döngü takibini başlatabilirsin 🌸';
    }
    switch (currentPhase) {
      case CyclePhase.period:
        return '🌸 Tavsiye: Dinlenme vakti! Sıcak çay ve battaniye iyi gelir.\n💖 Sevgili İpucu: Sıcak su torbası hazırla, şefkat göster ve sımsıkı sarıl! 🍫🤗';
      case CyclePhase.follicular:
        return '✨ Tavsiye: Enerjin ve canlılığın yükseliyor! Spora ve hobilere vakit ayır.\n🔥 Sevgili İpucu: Enerjisi yüksek! Romantik ve tutkulu bir randevu planlayabilirsin! ☕⚡';
      case CyclePhase.ovulation:
        return '🌟 Tavsiye: Östrojen ve libido zirvede! Işıltın tavan yapmış durumda.\n🔥 Sevgili İpucu: Arzu ve cinsel çekim en yüksek seviyede! Tutkulu yakınlaşmalar için mükemmel an 💐🔥';
      case CyclePhase.luteal:
        return '🌙 Tavsiye: Vücudun dinlenmeye hazırlanıyor. Bitki çayları ve hafif tatlılar harika gelecektir.\n🍿 Sevgili İpucu: Film gecesi hazırlığı yap, masaj yap ve şefkatli yaklaş 🎬💆‍♀️';
      case CyclePhase.late:
        return '🌿 Tavsiye: Hafif gecikmeler doğaldır. Sakinleştirici bitki çayları iç ve rahatla.\n💖 Sevgili İpucu: Rahat hissettir, endişelenmemesini sağla ve huzurlu ortam yarat 🍵';
      case CyclePhase.noData:
        return 'Lütfen takvimden bir tarih seçin.';
    }
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
