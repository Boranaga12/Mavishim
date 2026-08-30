import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/game_provider.dart';

const _differencePairs = <(String, String)>[
  ('●', '◆'),
  ('▲', '▼'),
  ('★', '☆'),
  ('♥', '♦'),
  ('○', '◉'),
  ('■', '□'),
  ('🌸', '🌺'),
  ('🌙', '⭐'),
  ('🍓', '🍒'),
  ('🐱', '🐶'),
  ('🦋', '🐝'),
  ('🍀', '🌿'),
  ('😊', '😉'),
  ('🥰', '😍'),
  ('💗', '💖'),
  ('☁️', '🌧️'),
  ('🍬', '🍭'),
  ('🎈', '🎀'),
  ('🐚', '🪸'),
  ('🌻', '🌼'),
  ('🧁', '🍰'),
  ('🐼', '🐨'),
  ('🫐', '🍇'),
  ('🎵', '🎶'),
  ('🔵', '🟣'),
  ('🔶', '🔷'),
  ('➕', '✖️'),
  ('☀️', '🌤️'),
  ('🪻', '🌷'),
  ('🐰', '🐹'),
  ('🍉', '🍈'),
  ('🌍', '🌎'),
  ('🕐', '🕑'),
  ('👑', '💎'),
  ('🧸', '🎁'),
  ('🚗', '🚕'),
];

const _loveSentences = <String>[
  'Boran Elifini her geçen gün daha çok seviyor ve Elifiyle kurduğu bütün güzel hayalleri ömrü boyunca kalbinde taşımak istiyor',
  'Boranın dünyası Elifi yanında olduğunda daha huzurlu daha renkli ve çok daha anlamlı bir yere dönüşüyor',
  'Elifin gülüşü Boranın en karanlık gününü aydınlatıyor sesi içini sakinleştiriyor ve sevgisi ona umut veriyor',
  'Boran için Elifiyle geçirdiği küçücük bir an bile Elifsiz geçen koskoca bir günden çok daha değerli geliyor',
  'Boranın kalbinin en güzel köşesi yalnızca Elifine ait çünkü Elifi onun sevgilisi sırdaşı mutluluğu ve bir tanesi',
  'Boran Elifinin elini tuttuğu her an bütün yolların sonunda yine Elifine varmak ve onunla yaşlanmak istiyor',
];

const _reactionPhrases = <String>[
  'Vay be, onu sonsuz çok seviyorsun!',
  'Kalbin Boran demek için ışık hızını geçti!',
  'Bu hız gerçek aşkın kesin kanıtı!',
  'Boran kalbinin tam merkezinde yaşıyor!',
  'Hımm, evet seviyorsun gibi görünüyor!',
  'Gayet hızlıydın, sevgin güçlü!',
  'Kalbin hiç düşünmeden EVET dedi!',
  'Boran bunu görse kesinlikle çok mutlu olurdu!',
  'Sevgi radarında oldukça yüksek çıktın!',
  'Biraz düşündün ama kalbin doğru cevabı verdi!',
  'Fena değil, Boran sevgisi hâlâ sıcak!',
  'Galiba naz yapıyorsun ama sevdiğin belli!',
  'Biraz daha hızlı olabilirdin sevgilim!',
  'Kalbinle beynin kısa bir toplantı yaptı galiba!',
  'Boran cevabını beklerken biraz heyecanlandı!',
  'Hiç de seviyor gibi değilsin, çok beklettin!',
  'Bu kadar düşünmek de ne, cevap zaten Boran!',
  'Geç bastın, demek ki sevgini biraz sorguladın!',
  'Boran beklemekten neredeyse umudunu kesecekti!',
  'Çok geç bastın; hemen bir sevgi sarılması borçlusun!',
];

class _WordLevel {
  final String letters;
  final List<String> words;
  const _WordLevel(this.letters, this.words);

  List<String> get puzzleWords {
    final result = words
        .where((word) => _canBuildWord(letters, word))
        .toSet()
        .toList();
    result.sort((a, b) {
      final lengthOrder = b.length.compareTo(a.length);
      return lengthOrder != 0 ? lengthOrder : a.compareTo(b);
    });
    return result;
  }

  List<String> get allWords {
    final result = <String>{...puzzleWords};
    for (final candidate in _wordCandidates) {
      if (_canBuildWord(letters, candidate)) result.add(candidate);
    }
    final sorted = result.toList();
    sorted.sort((a, b) {
      final lengthOrder = b.length.compareTo(a.length);
      return lengthOrder != 0 ? lengthOrder : a.compareTo(b);
    });
    return sorted;
  }
}

String _turkishLower(String value) =>
    value.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();

bool _canBuildWord(String source, String word) {
  final available = <String, int>{};
  for (final letter in _turkishLower(source).split('')) {
    available[letter] = (available[letter] ?? 0) + 1;
  }
  for (final letter in _turkishLower(word).split('')) {
    final remaining = available[letter] ?? 0;
    if (remaining == 0) return false;
    available[letter] = remaining - 1;
  }
  return word.length >= 2;
}

const _wordCandidates = <String>[
  'ad',
  'ak',
  'al',
  'an',
  'ar',
  'as',
  'at',
  'ay',
  'az',
  'bal',
  'bar',
  'baş',
  'ben',
  'bir',
  'biz',
  'bol',
  'bor',
  'boy',
  'bu',
  'can',
  'cam',
  'cici',
  'çiçek',
  'da',
  'dal',
  'dem',
  'dil',
  'diz',
  'dün',
  'el',
  'elim',
  'em',
  'en',
  'eş',
  'eşim',
  'et',
  'fal',
  'fil',
  'gül',
  'gün',
  'güneş',
  'hat',
  'hayat',
  'iç',
  'içim',
  'il',
  'ilim',
  'isim',
  'iz',
  'kal',
  'kalp',
  'kan',
  'kar',
  'kat',
  'kuş',
  'mal',
  'masal',
  'mat',
  'mel',
  'mert',
  'mum',
  'muş',
  'nar',
  'naz',
  'nefes',
  'net',
  'not',
  'ol',
  'on',
  'oran',
  'oy',
  'ömür',
  'pat',
  'pati',
  'patates',
  'pet',
  'rahat',
  'ruh',
  'saç',
  'sal',
  'sen',
  'ses',
  'sev',
  'sevgi',
  'simit',
  'su',
  'şan',
  'tam',
  'tan',
  'tane',
  'taş',
  'tat',
  'tema',
  'tepe',
  'ten',
  'ter',
  'uç',
  'umut',
  'un',
  'var',
  'yar',
  'yavru',
  'yaz',
  'yıldız',
  'yol',
  'acı',
  'acım',
  'ah',
  'ait',
  'ama',
  'amin',
  'anı',
  'ani',
  'ant',
  'arı',
  'art',
  'asım',
  'asma',
  'atma',
  'baron',
  'benim',
  'bina',
  'boran',
  'ceb',
  'cem',
  'doğum',
  'eğim',
  'emin',
  'emir',
  'emel',
  'empati',
  'esin',
  'evim',
  'fes',
  'film',
  'gel',
  'geli',
  'gemi',
  'geniş',
  'gişe',
  'ham',
  'hata',
  'istem',
  'iş',
  'işim',
  'kaş',
  'kaşım',
  'kış',
  'kışım',
  'kum',
  'lif',
  'lig',
  'malım',
  'mar',
  'mart',
  'masa',
  'matem',
  'mate',
  'maya',
  'mesai',
  'mest',
  'meta',
  'metin',
  'mil',
  'mine',
  'mis',
  'mod',
  'mor',
  'nam',
  'nem',
  'öbeğim',
  'örüm',
  'pas',
  'pasta',
  'pes',
  'ram',
  'rant',
  'retina',
  'roman',
  'rum',
  'sap',
  'sat',
  'satma',
  'semt',
  'sempati',
  'set',
  'sima',
  'sim',
  'simge',
  'simli',
  'sinem',
  'sine',
  'site',
  'talim',
  'tas',
  'team',
  'temas',
  'tepsi',
  'terim',
  'tespit',
  'tiner',
  'tip',
  'tim',
  'tren',
  'varım',
  'veli',
  'vur',
  'yam',
  'yama',
  'yat',
  'yatım',
  'yıl',
  'yılım',
  'yum',
  'çim',
  'çiğ',
  'akış',
  'aşık',
  'aşım',
  'amber',
  'amir',
  'anemi',
  'anime',
  'antre',
  'bant',
  'barem',
  'baret',
  'barit',
  'barmen',
  'bateri',
  'bent',
  'berat',
  'beta',
  'betim',
  'biat',
  'bin',
  'biner',
  'bira',
  'bit',
  'bora',
  'ebat',
  'eğe',
  'eğil',
  'eğilme',
  'eğitme',
  'eğme',
  'eman',
  'emtia',
  'enfes',
  'ense',
  'entari',
  'erat',
  'esef',
  'esen',
  'esim',
  'esme',
  'etap',
  'etamin',
  'etme',
  'fiil',
  'file',
  'imge',
  'imgeli',
  'iman',
  'imar',
  'imaret',
  'inat',
  'inme',
  'ispat',
  'itaat',
  'kam',
  'kamış',
  'lime',
  'lise',
  'mabet',
  'mahya',
  'mani',
  'matine',
  'melek',
  'meşin',
  'minare',
  'minber',
  'namert',
  'nebat',
  'nefis',
  'nimet',
  'norm',
  'oba',
  'onar',
  'onarım',
  'orman',
  'pest',
  'pim',
  'pis',
  'pist',
  'puf',
  'saat',
  'sapa',
  'sapma',
  'sema',
  'semai',
  'sene',
  'sevi',
  'sevim',
  'sevimli',
  'silgi',
  'silme',
  'sitem',
  'step',
  'tabir',
  'tamir',
  'tapa',
  'tapma',
  'tasma',
  'tatma',
  'temin',
  'tepme',
  'test',
  'testi',
  'vurma',
  'yuva',
  'yuvar',
  'anım',
  'alım',
  'akım',
  'cicim',
  'gülüm',
  'kuşum',
  'ruhum',
  'yavrum',
  'balım',
  'canım',
  'aşk',
  'aşkım',
  'elifim',
  'boranım',
  'ömrüm',
  'gubuş',
  'gubuşum',
  'birtanem',
  'hayatım',
  'peteğim',
  'pofuduğum',
  'patatesim',
  'çiçeğim',
  'böceğim',
  'meleğim',
  'güneşim',
  'yıldızım',
  'nefesim',
  'sevgilim',
];

const _wordLevels = <_WordLevel>[
  _WordLevel('BORANIM', [
    'boranım',
    'boran',
    'baron',
    'roman',
    'anım',
    'oran',
    'bar',
    'bor',
    'nar',
    'mor',
    'ram',
    'nam',
    'anı',
    'arı',
  ]),
  _WordLevel('ELİFİM', [
    'elifim',
    'ilim',
    'elim',
    'film',
    'fil',
    'mil',
    'lif',
    'il',
    'el',
  ]),
  _WordLevel('GUBUŞUM', ['gubuşum', 'gubuş', 'muş']),
  _WordLevel('CANIM', [
    'canım',
    'anım',
    'acım',
    'can',
    'cam',
    'acı',
    'anı',
    'nam',
  ]),
  _WordLevel('CİCİM', ['cicim', 'cici']),
  _WordLevel('SEVGİLİM', [
    'sevgilim',
    'sevgi',
    'sevgim',
    'simge',
    'ilgim',
    'ilgi',
    'simli',
    'gemi',
    'evim',
    'elim',
    'isim',
    'veli',
    'silgi',
    'gel',
    'sil',
    'mil',
    'mis',
    'sim',
  ]),
  _WordLevel('AŞKIM', [
    'aşkım',
    'kaşım',
    'kışım',
    'aşk',
    'akım',
    'kaş',
    'kış',
    'ak',
    'aş',
  ]),
  _WordLevel('ÖMRÜM', ['ömrüm', 'ömür', 'örüm']),
  _WordLevel('BİRTANEM', [
    'birtanem',
    'retina',
    'metin',
    'tiner',
    'benim',
    'terim',
    'emir',
    'emin',
    'mert',
    'tren',
    'mera',
    'bir',
    'tane',
    'ant',
    'art',
    'ait',
    'nem',
    'net',
    'ten',
    'ter',
    'tam',
  ]),
  _WordLevel('HAYATIM', [
    'hayatım',
    'hayat',
    'yatım',
    'hata',
    'maya',
    'yama',
    'asma',
    'atma',
    'satma',
    'hat',
    'yat',
    'yam',
    'ham',
    'tam',
    'mat',
    'ama',
  ]),
  _WordLevel('BALIM', ['balım', 'malım', 'alım', 'bal', 'mal']),
  _WordLevel('PETEĞİM', ['peteğim', 'eğim', 'tepe', 'tip', 'tim', 'pet']),
  _WordLevel('POFUDUĞUM', ['pofuduğum', 'doğum', 'mod', 'of', 'uf']),
  _WordLevel('PATATESİM', [
    'patatesim',
    'patates',
    'sempati',
    'empati',
    'tespit',
    'mesai',
    'tepsi',
    'temas',
    'pasta',
    'satma',
    'atma',
    'istem',
    'mesai',
    'masa',
    'asma',
    'sima',
    'site',
    'sitem',
    'testi',
  ]),
  _WordLevel('ÇİÇEĞİM', ['çiçeğim', 'içim', 'eğim', 'çiğ', 'çim', 'iç']),
  _WordLevel('BÖCEĞİM', ['böceğim', 'öbeğim', 'eğim', 'cem', 'ceb']),
  _WordLevel('KUŞUM', ['kuşum', 'kuş']),
  _WordLevel('GÜLÜM', ['gülüm', 'gül']),
  _WordLevel('YAVRUM', ['yavrum', 'yavru']),
  _WordLevel('RUHUM', ['ruhum', 'ruh']),
  _WordLevel('MELEĞİM', [
    'meleğim',
    'emel',
    'elim',
    'eğim',
    'mil',
    'ile',
    'el',
  ]),
  _WordLevel('GÜNEŞİM', [
    'güneşim',
    'güneş',
    'geniş',
    'eşim',
    'işim',
    'gemi',
    'gişe',
    'menü',
    'gün',
    'nem',
    'iş',
    'eş',
  ]),
  _WordLevel('YILDIZIM', ['yıldızım', 'yıldız', 'yılım', 'yıl']),
  _WordLevel('NEFESİM', [
    'nefesim',
    'nefes',
    'sinem',
    'esin',
    'emin',
    'mine',
    'sine',
    'nem',
    'sen',
    'ses',
    'fes',
    'mis',
    'sim',
  ]),
];

enum CuteArcadeGame {
  patternMemory,
  spotDifference,
  quickTap,
  maze,
  slidingPuzzle,
  wordHunt,
  reaction,
  miniSudoku,
  targetShot,
}

extension CuteArcadeGameInfo on CuteArcadeGame {
  String get title => switch (this) {
    CuteArcadeGame.patternMemory => 'Desen Hafızası',
    CuteArcadeGame.spotDifference => 'Farkı Bul',
    CuteArcadeGame.quickTap => 'Hızlı Dokun',
    CuteArcadeGame.maze => 'Pembe Labirent',
    CuteArcadeGame.slidingPuzzle => 'Kaydırmalı Yapboz',
    CuteArcadeGame.wordHunt => 'Kelime Avı',
    CuteArcadeGame.reaction => 'Tepki Testi',
    CuteArcadeGame.miniSudoku => 'Mini Sudoku',
    CuteArcadeGame.targetShot => 'Hedefe Atış',
  };

  String get description => switch (this) {
    CuteArcadeGame.patternMemory => 'Parlayan kutuların sırasını tekrarla.',
    CuteArcadeGame.spotDifference => 'Kalabalığın içindeki farklı şekli bul.',
    CuteArcadeGame.quickTap =>
      'Sevgi cümlesini süre dolmadan kelime kelime tamamla.',
    CuteArcadeGame.maze => 'Elif’i süre dolmadan Boran’a ulaştır.',
    CuteArcadeGame.slidingPuzzle =>
      'Sekiz parçayı kaydırıp doğru sıraya getir.',
    CuteArcadeGame.wordHunt => 'Karışık harflerden doğru kelimeyi oluştur.',
    CuteArcadeGame.reaction =>
      'Yeşil EVET’i yakala ve sevgini yüzdeyle göster.',
    CuteArcadeGame.miniSudoku => '4×4 E, L, İ, F tablosunu tamamla.',
    CuteArcadeGame.targetShot => 'Konum, açı ve güçle sevgini Boran’a ulaştır.',
  };

  IconData get icon => switch (this) {
    CuteArcadeGame.patternMemory => Icons.apps_rounded,
    CuteArcadeGame.spotDifference => Icons.search_rounded,
    CuteArcadeGame.quickTap => Icons.touch_app_rounded,
    CuteArcadeGame.maze => Icons.route_rounded,
    CuteArcadeGame.slidingPuzzle => Icons.extension_rounded,
    CuteArcadeGame.wordHunt => Icons.spellcheck_rounded,
    CuteArcadeGame.reaction => Icons.bolt_rounded,
    CuteArcadeGame.miniSudoku => Icons.grid_4x4_rounded,
    CuteArcadeGame.targetShot => Icons.gps_fixed_rounded,
  };
}

class CuteArcadeGameView extends StatefulWidget {
  final CuteArcadeGame game;

  const CuteArcadeGameView({super.key, required this.game});

  @override
  State<CuteArcadeGameView> createState() => _CuteArcadeGameViewState();
}

class _CuteArcadeGameViewState extends State<CuteArcadeGameView>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final _random = Random();
  Timer? _timer;
  int _score = 0;
  int _best = 0;
  int _lives = 3;
  bool get _nightMode => Theme.of(context).brightness == Brightness.dark;
  bool _ended = false;
  bool _showingResult = false;
  bool _hasPlayed = false;
  bool _recordCelebrated = false;
  int _roundTotalSeconds = 20;
  final Map<int, String> _quickTargets = {};
  List<String> _quickWords = [];
  int _quickWordIndex = 0;
  final Stopwatch _stopwatch = Stopwatch();
  DateTime? _reactionStarted;
  late ConfettiController _confetti;
  late AnimationController _aimMotion;
  late AnimationController _powerMotion;
  late AnimationController _angleMotion;
  late AnimationController _launchMotion;
  int _shotStage = 0;
  double _power = .5;
  double _angle = 0;
  double _targetY = .18;
  Offset _shotEnd = const Offset(.5, .2);
  int _target = 0;
  int _differenceStyle = 0;
  int _seconds = 20;
  int _position = 0;
  int _mazeSide = 5;
  Set<(int, int)> _mazePassages = {};
  Set<int> _mazeExits = {};
  bool _mazeReuniting = false;
  int _activeTile = -1;
  int _step = 0;
  double _aim = 0.5;
  double _targetAim = 0.5;
  bool _ready = false;
  bool _inputEnabled = true;
  String _message = '';
  late List<int> _board;
  List<int> _sequence = [];
  final List<int> _wordSelected = [];
  final Set<String> _foundWords = {};
  List<String> _wordLetters = [];
  Offset? _wordPointer;
  _WordCrossword? _wordCrossword;
  String _reactionButtonText = 'Boranını seviyor musun?';
  String _reactionFeedback = '';

  String get _progressKey => 'arcade_${widget.game.name}';
  bool get _isTimedGame => const {
    CuteArcadeGame.spotDifference,
    CuteArcadeGame.quickTap,
    CuteArcadeGame.maze,
  }.contains(widget.game);
  Color? get _timeDangerColor {
    if (!_isTimedGame || _seconds > 6) return null;
    final danger = (1 - _seconds / 7).clamp(0.0, 1.0);
    return Color.lerp(const Color(0xFFFFEEF5), const Color(0xFFFF8A8A), danger);
  }

  String get _appScoreText => switch (widget.game) {
    CuteArcadeGame.targetShot ||
    CuteArcadeGame.reaction => 'Sevgi %$_score • Maksimum %$_best',
    CuteArcadeGame.slidingPuzzle || CuteArcadeGame.miniSudoku =>
      'Rekor ${_best == 0 ? '-' : '${(_best / 1000).toStringAsFixed(1)} sn'}',
    _ => 'Skor $_score • Maksimum $_best',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _best = context.read<GameProvider>().progressFor(_progressKey);
    if ((widget.game == CuteArcadeGame.reaction ||
            widget.game == CuteArcadeGame.targetShot) &&
        _best > 100) {
      _best = 0;
      context.read<GameProvider>().saveProgress(_progressKey, 0);
    }
    _confetti = ConfettiController(duration: const Duration(milliseconds: 900));
    _aimMotion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
      animationBehavior: AnimationBehavior.preserve,
    )..repeat(reverse: true);
    _powerMotion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      animationBehavior: AnimationBehavior.preserve,
    );
    _angleMotion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      animationBehavior: AnimationBehavior.preserve,
    );
    _launchMotion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
      animationBehavior: AnimationBehavior.preserve,
    );
    _stopwatch.start();
    _resetRound();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _stopwatch.stop();
    _confetti.dispose();
    _aimMotion.dispose();
    _powerMotion.dispose();
    _angleMotion.dispose();
    _launchMotion.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _timer?.cancel();
      return;
    }
    if (_isTimedGame && _seconds > 0) {
      _startCountdown();
    } else if (widget.game == CuteArcadeGame.reaction) {
      _scheduleReaction();
    }
  }

  void _persistScore(int value) {
    _score = value;
    if (value > _best) {
      _best = value;
      context.read<GameProvider>().saveProgress(_progressKey, value);
      if (!_recordCelebrated) {
        _recordCelebrated = true;
        _confetti.play();
      }
    }
  }

  void _resetRound() {
    _timer?.cancel();
    _seconds = 20;
    _lives = 3;
    _ended = false;
    _position = 0;
    _step = 0;
    _activeTile = -1;
    _ready = false;
    _shotStage = 0;
    _aimMotion.repeat(reverse: true);
    _powerMotion.stop();
    _angleMotion.stop();
    _launchMotion.reset();
    _mazeReuniting = false;
    _inputEnabled = true;
    _message = '';
    _board = List.generate(36, (index) => index);
    switch (widget.game) {
      case CuteArcadeGame.patternMemory:
        _sequence = List.generate(
          min(3 + _score, 9),
          (_) => _random.nextInt(9),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) => _showSequence());
      case CuteArcadeGame.spotDifference:
        _target = _random.nextInt(36);
        _differenceStyle = _random.nextInt(_differencePairs.length);
        _seconds = max(4, 12 - _score ~/ 2);
        _roundTotalSeconds = _seconds;
        _startCountdown();
      case CuteArcadeGame.quickTap:
        _quickWords = (_loveSentences[_random.nextInt(_loveSentences.length)]
            .split(' '));
        _quickWordIndex = 0;
        _quickTargets.clear();
        _addQuickTarget();
        _roundTotalSeconds = _seconds;
        _startCountdown();
      case CuteArcadeGame.maze:
        _makeMaze();
        _seconds = max(9, 28 - _score * 2);
        _roundTotalSeconds = _seconds;
        _startCountdown();
      case CuteArcadeGame.slidingPuzzle:
        _stopwatch
          ..reset()
          ..start();
        _board = List.generate(9, (index) => index);
        for (var i = 0; i < 120; i++) {
          final blank = _board.indexOf(0);
          final choices = _adjacent(blank, 3);
          final next = choices[_random.nextInt(choices.length)];
          final value = _board[next];
          _board[next] = 0;
          _board[blank] = value;
        }
      case CuteArcadeGame.wordHunt:
        _target = _random.nextInt(_wordLevels.length);
        final level = _wordLevels[_target];
        _wordLetters = level.letters.split('')..shuffle(_random);
        _wordSelected.clear();
        _foundWords.clear();
        _wordCrossword = _WordCrossword.generate(
          level.puzzleWords,
          seed: _target * 7919 + level.puzzleWords.length,
        );
      case CuteArcadeGame.reaction:
        _reactionButtonText = 'Boranını seviyor musun?';
        _scheduleReaction();
      case CuteArcadeGame.miniSudoku:
        _stopwatch
          ..reset()
          ..start();
        _board = [1, 0, 3, 0, 0, 4, 0, 2, 2, 0, 4, 0, 0, 3, 0, 1];
      case CuteArcadeGame.targetShot:
        _targetAim = 0.12 + _random.nextDouble() * 0.76;
        _targetY = .1 + _random.nextDouble() * .35;
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _seconds--;
        if (_seconds <= 0) {
          _timer?.cancel();
          _message = widget.game == CuteArcadeGame.maze
              ? 'Aşıklar kavuşamadı.'
              : 'Süre doldu • Puanın: $_score';
          _ended = true;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _showResult(_message),
          );
        }
      });
    });
  }

  Future<void> _showSequence() async {
    if (!mounted) return;
    setState(() => _inputEnabled = false);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    for (final tile in _sequence) {
      if (!mounted) return;
      setState(() => _activeTile = tile);
      await Future<void>.delayed(const Duration(milliseconds: 420));
      if (!mounted) return;
      setState(() => _activeTile = -1);
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
    if (mounted) setState(() => _inputEnabled = true);
  }

  void _sequenceTap(int index) {
    if (!_inputEnabled) return;
    _hasPlayed = true;
    if (_sequence[_step] != index) {
      _lives--;
      if (_lives <= 0) {
        _ended = true;
        _showResult('Ulaştığın desen seviyesi: $_score');
        return;
      }
      setState(() {
        _message = 'Yanlış sıra! $_lives canın kaldı.';
        _step = 0;
      });
      _showSequence();
      return;
    }
    _step++;
    if (_step == _sequence.length) {
      _persistScore(_score + 1);
      setState(_resetRound);
    } else {
      setState(() {});
    }
  }

  void _pickDifference(int index) {
    _hasPlayed = true;
    if (index != _target) {
      setState(() => _message = 'Çok yakın, bir daha bak 🌸');
      return;
    }
    _persistScore(_score + 1);
    setState(_resetRound);
  }

  void _quickTap(int index) {
    if (_seconds <= 0 || !_quickTargets.containsKey(index)) return;
    _hasPlayed = true;
    _persistScore(_score + 1);
    setState(() {
      _quickTargets.remove(index);
      _addQuickTarget();
      if (_seconds < 10 && _quickTargets.length < 2) _addQuickTarget();
    });
  }

  void _addQuickTarget() {
    var next = _random.nextInt(30);
    while (_quickTargets.containsKey(next)) {
      next = _random.nextInt(30);
    }
    _quickTargets[next] = _quickWords[_quickWordIndex % _quickWords.length];
    _quickWordIndex++;
  }

  void _move(int delta) {
    if (_mazeReuniting) return;
    final next = _position + delta;
    if (!_adjacent(_position, _mazeSide).contains(next) ||
        !_mazePassages.contains(_edge(_position, next))) {
      return;
    }
    _hasPlayed = true;
    setState(() => _position = next);
    context.read<GameProvider>().saveProgress('${_progressKey}_position', next);
    if (_mazeExits.contains(next)) {
      _timer?.cancel();
      setState(() {
        _mazeReuniting = true;
        _message = 'Aşıklar kavuştu 💞';
      });
      Future<void>.delayed(const Duration(milliseconds: 1800), () {
        if (!mounted || _ended) return;
        _persistScore(_score + 1);
        setState(_resetRound);
      });
    }
  }

  (int, int) _edge(int a, int b) => a < b ? (a, b) : (b, a);

  void _makeMaze() {
    _mazeSide = min(11, 5 + (_score ~/ 2) * 2);
    _position = 0;
    final candidates = <int>{
      for (var i = 1; i < _mazeSide; i++) i * _mazeSide + _mazeSide - 1,
      for (var i = 1; i < _mazeSide; i++) (_mazeSide - 1) * _mazeSide + i,
    }.toList()..shuffle(_random);
    _mazeExits = {candidates.first};
    _target = _mazeExits.first;
    _mazePassages = {};
    final visited = <int>{0};
    final stack = <int>[0];
    while (stack.isNotEmpty) {
      final current = stack.last;
      final choices = _adjacent(
        current,
        _mazeSide,
      ).where((cell) => !visited.contains(cell)).toList();
      if (choices.isEmpty) {
        stack.removeLast();
      } else {
        final next = choices[_random.nextInt(choices.length)];
        _mazePassages.add(_edge(current, next));
        visited.add(next);
        stack.add(next);
      }
    }
  }

  List<int> _adjacent(int index, int side) => [
    if (index ~/ side > 0) index - side,
    if (index ~/ side < side - 1) index + side,
    if (index % side > 0) index - 1,
    if (index % side < side - 1) index + 1,
  ];

  void _slide(int index) {
    final blank = _board.indexOf(0);
    final sameRow = blank ~/ 3 == index ~/ 3;
    final sameColumn = blank % 3 == index % 3;
    if (!sameRow && !sameColumn) return;
    final distance = sameRow
        ? (blank - index).abs()
        : (blank - index).abs() ~/ 3;
    if (distance == 0 || distance > 2) return;
    _hasPlayed = true;
    final delta = sameRow ? (index > blank ? 1 : -1) : (index > blank ? 3 : -3);
    setState(() {
      var cursor = blank;
      while (cursor != index) {
        _board[cursor] = _board[cursor + delta];
        cursor += delta;
      }
      _board[index] = 0;
    });
    if (_board.join(',') == '1,2,3,4,5,6,7,8,0') {
      _stopwatch.stop();
      final elapsed = max(1, _stopwatch.elapsedMilliseconds);
      _score = elapsed;
      if (_best == 0 || elapsed < _best) {
        _best = elapsed;
        context.read<GameProvider>().saveProgress(_progressKey, elapsed);
        _confetti.play();
      }
      _ended = true;
      _showResult('Yapboz tamamlandı! ✨');
    }
  }

  void _wordDragLetter(int index) {
    if (_wordSelected.contains(index)) return;
    _hasPlayed = true;
    setState(() => _wordSelected.add(index));
  }

  void _finishWordDrag(List<String> letters) {
    if (_wordSelected.isEmpty) return;
    final word = _wordSelected
        .map((index) => letters[index])
        .join()
        .replaceAll('I', 'ı')
        .replaceAll('İ', 'i')
        .toLowerCase();
    final level = _wordLevels[_target];
    if (level.allWords.contains(word)) {
      if (!_foundWords.add(word)) {
        _message = '“$word” kelimesini zaten buldun.';
      } else {
        _message = level.puzzleWords.contains(word)
            ? 'Harika! “$word” şemada açıldı.'
            : 'Bonus kelime: “$word” ✨';
        _persistScore(_score + 1);
      }
      if (level.puzzleWords.every(_foundWords.contains)) {
        _ended = true;
        _showResult('Bölüm tamamlandı!');
      }
    } else {
      _message = '“$word” bu bölümde yok.';
    }
    setState(() {
      _wordSelected.clear();
      _wordPointer = null;
    });
  }

  void _scheduleReaction() {
    _ready = false;
    _reactionButtonText = 'Boranını seviyor musun?';
    _reactionFeedback = '';
    _message = '';
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: 2600 + _random.nextInt(3000)), () {
      if (mounted) {
        setState(() {
          _ready = true;
          _reactionStarted = DateTime.now();
          _reactionButtonText = 'EVET';
        });
      }
    });
  }

  void _reactionTap() {
    _hasPlayed = true;
    if (!_ready) {
      _timer?.cancel();
      setState(() {
        _reactionButtonText = 'Boranını seviyor musun?';
        _reactionFeedback = 'Vay be, onu sonsuz çok seviyorsun!';
        _message = 'Daha “EVET” demeden kalbin cevap verdi 💙';
      });
      _timer = Timer(const Duration(milliseconds: 1800), _scheduleReaction);
      return;
    }
    final elapsed = DateTime.now().difference(_reactionStarted!).inMilliseconds;
    final percent = (112 - elapsed / 11).round().clamp(0, 100);
    _persistScore(percent);
    final phraseIndex = ((100 - percent) * _reactionPhrases.length ~/ 101)
        .clamp(0, _reactionPhrases.length - 1);
    setState(() {
      _ready = false;
      _reactionButtonText = 'Boranını seviyor musun?';
      _reactionFeedback = _reactionPhrases[phraseIndex];
      _message = '$elapsed ms • Boran sevgisi: %$percent';
    });
    _timer = Timer(const Duration(milliseconds: 1900), _scheduleReaction);
  }

  void _sudokuTap(int index) {
    const fixed = {0, 2, 5, 7, 8, 10, 13, 15};
    if (fixed.contains(index)) return;
    _hasPlayed = true;
    setState(() => _board[index] = _board[index] % 4 + 1);
    context.read<GameProvider>().saveProgress(
      '${_progressKey}_moves',
      _score + 1,
    );
    const solution = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1];
    if (_board.join(',') == solution.join(',')) {
      _stopwatch.stop();
      final elapsed = max(1, _stopwatch.elapsedMilliseconds);
      _score = elapsed;
      if (_best == 0 || elapsed < _best) {
        _best = elapsed;
        context.read<GameProvider>().saveProgress(_progressKey, elapsed);
        _confetti.play();
      }
      _ended = true;
      _showResult('Sudoku tamamlandı! 🌸');
    }
  }

  void _shoot() {
    if (_shotStage == 0) {
      _hasPlayed = true;
      _aim = _aimMotion.value;
      _aimMotion.stop();
      _angleMotion.repeat(reverse: true);
      setState(() => _shotStage = 1);
      return;
    }
    if (_shotStage == 1) {
      _angle = -.55 + _angleMotion.value * 1.1;
      _angleMotion.stop();
      _powerMotion.repeat(reverse: true);
      setState(() => _shotStage = 2);
      return;
    }
    if (_shotStage == 2) {
      _power = _powerMotion.value;
      _powerMotion.stop();
      setState(() => _shotStage = 3);
      return;
    }
    if (_shotStage != 3) return;
    final travel = .34 + _power * .64;
    _shotEnd = Offset(
      (_aim + sin(_angle) * travel).clamp(.02, .98),
      (.9 - cos(_angle) * travel).clamp(.04, .92),
    );
    setState(() => _shotStage = 4);
    _launchMotion.forward(from: 0).then((_) {
      if (!mounted) return;
      final distance = (_shotEnd - Offset(_targetAim, _targetY)).distance;
      final love = (100 - distance * 125).round().clamp(0, 100);
      _persistScore(love);
      _ended = true;
      _message = 'Boranına olan sevgin: %$love';
      _showResult('');
    });
  }

  Future<void> _showResult(String detail, {bool stopped = false}) async {
    if (!mounted || _showingResult) return;
    if (stopped && !_hasPlayed && _score == 0) {
      Navigator.of(context).pop();
      return;
    }
    _showingResult = true;
    final lowerIsBetter = const {
      CuteArcadeGame.slidingPuzzle,
      CuteArcadeGame.miniSudoku,
    }.contains(widget.game);
    if (stopped) {
      final partial =
          (widget.game == CuteArcadeGame.slidingPuzzle ||
              widget.game == CuteArcadeGame.miniSudoku)
          ? _stopwatch.elapsedMilliseconds
          : _score;
      await context.read<GameProvider>().saveProgress(
        '${_progressKey}_partial',
        partial,
      );
      if (!mounted) return;
    }
    if (!lowerIsBetter && _score > _best) _persistScore(_score);
    final scoreText = switch (widget.game) {
      CuteArcadeGame.targetShot =>
        'Boranına olan sevgin: %$_score\nMaksimum sevgi: %$_best',
      CuteArcadeGame.reaction =>
        'Boran sevgisi: %$_score\nMaksimum sevgi: %$_best',
      CuteArcadeGame.slidingPuzzle || CuteArcadeGame.miniSudoku =>
        'Süre: ${(_score / 1000).toStringAsFixed(2)} sn\nRekor: ${(_best / 1000).toStringAsFixed(2)} sn',
      _ => 'Skor: $_score • Maksimum: $_best',
    };
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        title: const Text('Oyun bitti'),
        content: Text('${detail.isEmpty ? '' : '$detail\n\n'}$scoreText'),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Geri çık'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() {
                _score = 0;
                _hasPlayed = false;
                _recordCelebrated = false;
                _showingResult = false;
                _stopwatch
                  ..reset()
                  ..start();
                _resetRound();
              });
            },
            child: const Text('Tekrar oyna'),
          ),
        ],
      ),
    );
    _showingResult = false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showResult('', stopped: true);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: _nightMode ? const Color(0xFF101725) : null,
          foregroundColor: _nightMode ? Colors.white : null,
          title: Text(widget.game.title),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  _appScoreText,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 52),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: _nightMode || _timeDangerColor != null
                      ? null
                      : AppTheme.backgroundGradient,
                  color: _nightMode
                      ? const Color(0xFF101725)
                      : _timeDangerColor,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          widget.game.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _nightMode ? Colors.white : null,
                          ),
                        ),
                        if (widget.game == CuteArcadeGame.patternMemory)
                          Text(
                            'Can: ${'♥' * _lives} • ${_inputEnabled ? 'Sıra sende' : 'Deseni izle'}',
                            style: TextStyle(
                              color: _nightMode
                                  ? Colors.white
                                  : AppTheme.deepPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        SizedBox(
                          height: 46,
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              child: Text(
                                _message,
                                key: ValueKey(_message),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _nightMode ? Colors.white : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: DefaultTextStyle.merge(
                            style: TextStyle(
                              color: _nightMode ? Colors.white : null,
                            ),
                            child: _gameBody(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isTimedGame && _seconds <= 5 && !_ended)
              Positioned.fill(
                child: IgnorePointer(
                  child: _TimePressureOverlay(
                    seconds: _seconds,
                    totalSeconds: _roundTotalSeconds,
                  ),
                ),
              ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gameBody() => switch (widget.game) {
    CuteArcadeGame.patternMemory => _sequenceGrid(9),
    CuteArcadeGame.spotDifference => _differenceGrid(false),
    CuteArcadeGame.quickTap => _quickGrid(),
    CuteArcadeGame.maze => _maze(),
    CuteArcadeGame.slidingPuzzle => _sliding(),
    CuteArcadeGame.wordHunt => _wordHunt(),
    CuteArcadeGame.reaction => _reaction(),
    CuteArcadeGame.miniSudoku => _sudoku(),
    CuteArcadeGame.targetShot => _targetGame(),
  };

  Widget _grid(int count, int columns, Widget Function(int) child) =>
      GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (_, index) => child(index),
      );

  Widget _sequenceGrid(int count) => _grid(
    count,
    3,
    (index) => _tile(
      color: _activeTile == index
          ? AppTheme.primaryPink
          : !_inputEnabled
          ? const Color(0xFF687386)
          : _nightMode
          ? const Color(0xFF26364B)
          : Colors.white,
      onTap: () => _sequenceTap(index),
      child: Icon(
        Icons.favorite,
        color: _activeTile == index ? Colors.white : Colors.pink.shade200,
      ),
    ),
  );

  Widget _differenceGrid(bool emoji) => Column(
    children: [
      if (!emoji)
        Text(
          'Tur ${_score + 1} • $_seconds sn',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      const SizedBox(height: 8),
      Expanded(
        child: _grid(
          36,
          6,
          (index) => _tile(
            onTap: () => _pickDifference(index),
            child: Text(
              emoji
                  ? (index == _target ? '😺' : '😸')
                  : (index == _target
                        ? _differencePairs[_differenceStyle].$2
                        : _differencePairs[_differenceStyle].$1),
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _quickGrid() => Column(
    children: [
      Text(
        'Süre: $_seconds sn${_quickTargets.length == 2 ? ' • Çift hedef!' : ''}',
      ),
      const SizedBox(height: 10),
      Expanded(
        child: _grid(
          30,
          5,
          (index) => _tile(
            onTap: () => _quickTap(index),
            color: _quickTargets.containsKey(index)
                ? AppTheme.primaryPink
                : Colors.white,
            child: _quickTargets.containsKey(index)
                ? Padding(
                    padding: const EdgeInsets.all(3),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _quickTargets[index]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    ],
  );

  Widget _maze() => Column(
    children: [
      Text('$_seconds sn • $_mazeSide×$_mazeSide • ${_mazeExits.length} çıkış'),
      Expanded(
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: _MazeBoardPainter(
                side: _mazeSide,
                passages: _mazePassages,
                position: _position,
                targets: _mazeExits,
                reuniting: _mazeReuniting,
              ),
            ),
          ),
        ),
      ),
      SizedBox(
        width: 150,
        height: 130,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 51,
              child: _arrow(Icons.arrow_upward, -_mazeSide),
            ),
            Positioned(left: 4, top: 43, child: _arrow(Icons.arrow_back, -1)),
            Positioned(
              right: 4,
              top: 43,
              child: _arrow(Icons.arrow_forward, 1),
            ),
            Positioned(
              bottom: 0,
              left: 51,
              child: _arrow(Icons.arrow_downward, _mazeSide),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _arrow(IconData icon, int delta) => Material(
    color: AppTheme.primaryPink,
    borderRadius: BorderRadius.circular(12),
    child: IconButton(
      onPressed: () => _move(delta),
      icon: Icon(icon, color: Colors.white),
    ),
  );

  Widget _sliding() => Column(
    children: [
      _ElapsedTime(stopwatch: _stopwatch),
      const SizedBox(height: 8),
      Expanded(
        child: _grid(
          9,
          3,
          (index) => _board[index] == 0
              ? const SizedBox()
              : _tile(
                  onTap: () => _slide(index),
                  color: AppTheme.primaryPink,
                  child: Text(
                    '${_board[index]}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
      ),
      const Text('Aynı sıradaki iki taşı birlikte itebilirsin.'),
    ],
  );

  Widget _wordHunt() {
    final level = _wordLevels[_target];
    final words = level.puzzleWords;
    final letters = _wordLetters;
    final current = _wordSelected.map((index) => letters[index]).join();
    final crossword = _wordCrossword!;
    final foundInPuzzle = words.where(_foundWords.contains).length;
    final bonusCount = _foundWords.length - foundInPuzzle;
    return Column(
      children: [
        Text(
          '${level.letters} • $foundInPuzzle/${words.length} kelime${bonusCount == 0 ? '' : ' • $bonusCount bonus'}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: _WordCrosswordBoard(
            crossword: crossword,
            foundWords: _foundWords,
            nightMode: _nightMode,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          current.isEmpty ? 'Harfleri sürükleyerek birleştir aşkım' : current,
          style: const TextStyle(
            fontSize: 20,
            color: AppTheme.primaryPink,
            fontWeight: FontWeight.bold,
          ),
        ),
        Center(
          child: SizedBox(
            width: 220,
            height: 220,
            child: LayoutBuilder(
              builder: (_, box) {
                final center = Offset(box.maxWidth / 2, box.maxHeight / 2);
                final radius = min(91.0, box.maxWidth / 2 - 32);
                final points = List.generate(
                  letters.length,
                  (i) =>
                      center +
                      Offset(
                            cos(-pi / 2 + i * 2 * pi / letters.length),
                            sin(-pi / 2 + i * 2 * pi / letters.length),
                          ) *
                          radius,
                );
                int? hit(Offset point) {
                  for (var i = 0; i < points.length; i++) {
                    if ((points[i] - point).distance < 32) return i;
                  }
                  return null;
                }

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanDown: (details) {
                    final index = hit(details.localPosition);
                    if (index != null) _wordDragLetter(index);
                  },
                  onPanUpdate: (details) {
                    final index = hit(details.localPosition);
                    if (index != null) _wordDragLetter(index);
                    setState(() => _wordPointer = details.localPosition);
                  },
                  onPanEnd: (_) => _finishWordDrag(letters),
                  onPanCancel: () => setState(() {
                    _wordSelected.clear();
                    _wordPointer = null;
                  }),
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _LetterWheelPainter(
                      letters: letters,
                      points: points,
                      selected: _wordSelected,
                      pointer: _wordPointer,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _reaction() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 82,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Text(
                _reactionFeedback,
                key: ValueKey(_reactionFeedback),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: _reactionTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _ready ? Colors.green : AppTheme.primaryPink,
            ),
            child: Center(
              child: Text(
                _reactionButtonText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _sudoku() => Column(
    children: [
      _ElapsedTime(stopwatch: _stopwatch),
      const SizedBox(height: 8),
      Expanded(
        child: _grid(
          16,
          4,
          (index) => _tile(
            onTap: () => _sudokuTap(index),
            color: Colors.white,
            child: Text(
              _board[index] == 0
                  ? ''
                  : const ['', 'E', 'L', 'İ', 'F'][_board[index]],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _targetGame() => Column(
    children: [
      Expanded(
        child: LayoutBuilder(
          builder: (_, box) => AnimatedBuilder(
            animation: Listenable.merge([
              _aimMotion,
              _angleMotion,
              _powerMotion,
              _launchMotion,
            ]),
            builder: (_, _) {
              final aim = _shotStage == 0 ? _aimMotion.value : _aim;
              final liveAngle = _shotStage == 1
                  ? -.55 + _angleMotion.value * 1.1
                  : _angle;
              final start = Offset(aim, .9);
              final progress = Curves.easeOutCubic.transform(
                _launchMotion.value,
              );
              final heart = _shotStage == 4
                  ? Offset(
                      start.dx + (_shotEnd.dx - start.dx) * progress,
                      start.dy +
                          (_shotEnd.dy - start.dy) * progress -
                          sin(pi * progress) * .14,
                    )
                  : start;
              return Stack(
                children: [
                  Positioned(
                    left: _targetAim * (box.maxWidth - 62),
                    top: _targetY * (box.maxHeight - 34),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Boran',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: heart.dx * (box.maxWidth - 50),
                    top: heart.dy * (box.maxHeight - 50),
                    child: const Icon(
                      Icons.favorite,
                      color: Color(0xFF1877F2),
                      size: 50,
                    ),
                  ),
                  if (_shotStage >= 1 && _shotStage < 4)
                    Positioned(
                      left: aim * (box.maxWidth - 50) + 9,
                      bottom: 68,
                      child: Transform.rotate(
                        angle: liveAngle,
                        alignment: Alignment.bottomCenter,
                        child: const _AimArrow(),
                      ),
                    ),
                  if (_shotStage >= 2 && _shotStage < 4)
                    Positioned(
                      right: 8,
                      top: 35,
                      bottom: 35,
                      child: Container(
                        width: 22,
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.purple),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: FractionallySizedBox(
                          heightFactor: _shotStage == 2
                              ? _powerMotion.value
                              : _power,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPink,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
      FilledButton.icon(
        onPressed: _shotStage == 4 ? null : _shoot,
        icon: Icon(_shotStage < 3 ? Icons.stop_circle : Icons.favorite),
        label: Text(_shotStage < 3 ? 'Durdur' : 'Boranına sevgini göster'),
      ),
    ],
  );

  Widget _tile({
    Widget? child,
    Color color = Colors.white,
    VoidCallback? onTap,
  }) => Material(
    color: _nightMode && color == Colors.white
        ? const Color(0xFF27364B)
        : color,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Center(child: child),
    ),
  );
}

class _AimArrow extends StatelessWidget {
  const _AimArrow();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 56,
    height: 152,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Icon(
          Icons.arrow_drop_up_rounded,
          color: Color(0xFF1877F2),
          size: 46,
        ),
        Container(
          width: 6,
          height: 98,
          decoration: BoxDecoration(
            color: const Color(0xFF1877F2),
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [
              BoxShadow(color: Color(0x661877F2), blurRadius: 8),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ElapsedTime extends StatefulWidget {
  final Stopwatch stopwatch;
  const _ElapsedTime({required this.stopwatch});

  @override
  State<_ElapsedTime> createState() => _ElapsedTimeState();
}

class _TimePressureOverlay extends StatelessWidget {
  final int seconds;
  final int totalSeconds;

  const _TimePressureOverlay({
    required this.seconds,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    key: ValueKey(seconds),
    tween: Tween(begin: .82, end: 1),
    duration: const Duration(milliseconds: 450),
    curve: Curves.easeOutBack,
    builder: (_, pulse, _) => Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red.withValues(alpha: .35 + .2 * pulse),
                width: 7,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: .12 * pulse),
                  blurRadius: 45,
                  spreadRadius: 18,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 18,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(color: Colors.redAccent, blurRadius: 18),
                ],
              ),
              child: const Text(
                'ACELE ET!  •  SON SANİYELER',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
        if (seconds <= 3)
          Center(
            child: Transform.scale(
              scale: pulse,
              child: SizedBox(
                width: 245,
                height: 245,
                child: CustomPaint(
                  painter: _CountdownRingPainter(
                    progress: 1 - seconds / max(1, totalSeconds),
                  ),
                  child: Center(
                    child: Text(
                      '$seconds',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 108,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        shadows: const [
                          Shadow(color: Colors.white, blurRadius: 12),
                          Shadow(color: Colors.redAccent, blurRadius: 28),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _CountdownRingPainter extends CustomPainter {
  final double progress;
  const _CountdownRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 12;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: .52)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.red.withValues(alpha: .55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
    final angle = -pi / 2 + 2 * pi * progress;
    final marker = center + Offset(cos(angle), sin(angle)) * radius;
    canvas.drawCircle(marker, 11, Paint()..color = Colors.red.shade800);
    canvas.drawCircle(
      marker,
      19,
      Paint()..color = Colors.red.withValues(alpha: .2),
    );
  }

  @override
  bool shouldRepaint(covariant _CountdownRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _ElapsedTimeState extends State<_ElapsedTime> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text(
    '${(widget.stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1)} sn',
    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  );
}

class _MazeBoardPainter extends CustomPainter {
  final int side;
  final Set<(int, int)> passages;
  final int position;
  final Set<int> targets;
  final bool reuniting;

  const _MazeBoardPainter({
    required this.side,
    required this.passages,
    required this.position,
    required this.targets,
    required this.reuniting,
  });

  (int, int) _edge(int a, int b) => a < b ? (a, b) : (b, a);

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / side;
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    final wall = Paint()
      ..color = const Color(0xFF7B2E65)
      ..strokeWidth = 2;
    for (var index = 0; index < side * side; index++) {
      final row = index ~/ side;
      final column = index % side;
      final x = column * cell;
      final y = row * cell;
      if (row == 0 || !passages.contains(_edge(index, index - side))) {
        canvas.drawLine(Offset(x, y), Offset(x + cell, y), wall);
      }
      if (column == 0 || !passages.contains(_edge(index, index - 1))) {
        canvas.drawLine(Offset(x, y), Offset(x, y + cell), wall);
      }
      if (row == side - 1) {
        canvas.drawLine(Offset(x, y + cell), Offset(x + cell, y + cell), wall);
      }
      if (column == side - 1) {
        canvas.drawLine(Offset(x + cell, y), Offset(x + cell, y + cell), wall);
      }
    }
    Offset center(int index) =>
        Offset((index % side + .5) * cell, (index ~/ side + .5) * cell);
    if (reuniting) {
      final text = TextPainter(
        text: const TextSpan(
          text: 'Aşıklar\nkavuştu 💞',
          style: TextStyle(
            color: AppTheme.primaryPink,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: cell * 2.4);
      text.paint(
        canvas,
        center(position) - Offset(text.width / 2, text.height / 2),
      );
    } else {
      for (final target in targets) {
        _paintMazeName(canvas, center(target), 'Boran', Colors.blue, cell);
      }
      _paintMazeName(
        canvas,
        center(position),
        'Elif',
        AppTheme.primaryPink,
        cell,
      );
    }
  }

  void _paintMazeName(
    Canvas canvas,
    Offset center,
    String value,
    Color color,
    double cell,
  ) {
    final text = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: min(12, cell * .42),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, center - Offset(text.width / 2, text.height / 2));
  }

  @override
  bool shouldRepaint(covariant _MazeBoardPainter oldDelegate) =>
      oldDelegate.position != position ||
      oldDelegate.side != side ||
      oldDelegate.passages != passages ||
      oldDelegate.reuniting != reuniting;
}

typedef _WordCell = (int, int);

class _WordPlacement {
  final String word;
  final int row;
  final int column;
  final bool horizontal;

  const _WordPlacement({
    required this.word,
    required this.row,
    required this.column,
    required this.horizontal,
  });

  Iterable<_WordCell> get cells sync* {
    for (var index = 0; index < word.length; index++) {
      yield (row + (horizontal ? 0 : index), column + (horizontal ? index : 0));
    }
  }
}

class _WordCrossword {
  final Map<_WordCell, String> cells;
  final Map<_WordCell, Set<String>> cellWords;
  final int minRow;
  final int maxRow;
  final int minColumn;
  final int maxColumn;

  const _WordCrossword({
    required this.cells,
    required this.cellWords,
    required this.minRow,
    required this.maxRow,
    required this.minColumn,
    required this.maxColumn,
  });

  int get rows => maxRow - minRow + 1;
  int get columns => maxColumn - minColumn + 1;

  static _WordCrossword generate(List<String> source, {required int seed}) {
    final random = Random(seed);
    final words = source.toSet().toList()..shuffle(random);
    words.sort((a, b) => b.length.compareTo(a.length));
    final cells = <_WordCell, String>{};
    final placements = <_WordPlacement>[];

    void place(_WordPlacement placement) {
      placements.add(placement);
      var index = 0;
      for (final cell in placement.cells) {
        cells[cell] = placement.word[index++];
      }
    }

    if (words.isEmpty) {
      return const _WordCrossword(
        cells: {},
        cellWords: {},
        minRow: 0,
        maxRow: 0,
        minColumn: 0,
        maxColumn: 0,
      );
    }
    place(
      _WordPlacement(
        word: words.removeAt(0),
        row: 0,
        column: 0,
        horizontal: true,
      ),
    );

    final pending = List<String>.from(words);
    while (pending.isNotEmpty) {
      var addedInPass = false;
      for (final word in List<String>.from(pending)) {
        final candidate = _bestPlacement(word, cells, strict: true);
        if (candidate == null) continue;
        place(candidate);
        pending.remove(word);
        addedInPass = true;
      }
      if (addedInPass) continue;

      // Dense levels can run out of strict crossword spacing. Keep the board
      // connected while relaxing only the side-neighbour rule.
      final word = pending.removeAt(0);
      final relaxed = _bestPlacement(word, cells, strict: false);
      if (relaxed != null) {
        place(relaxed);
      } else {
        final bottom = cells.keys.map((cell) => cell.$1).reduce(max) + 2;
        place(
          _WordPlacement(word: word, row: bottom, column: 0, horizontal: true),
        );
      }
    }

    final cellWords = <_WordCell, Set<String>>{};
    for (final placement in placements) {
      for (final cell in placement.cells) {
        (cellWords[cell] ??= <String>{}).add(placement.word);
      }
    }
    final rows = cells.keys.map((cell) => cell.$1);
    final columns = cells.keys.map((cell) => cell.$2);
    return _WordCrossword(
      cells: cells,
      cellWords: cellWords,
      minRow: rows.reduce(min),
      maxRow: rows.reduce(max),
      minColumn: columns.reduce(min),
      maxColumn: columns.reduce(max),
    );
  }

  static _WordPlacement? _bestPlacement(
    String word,
    Map<_WordCell, String> cells, {
    required bool strict,
  }) {
    _WordPlacement? best;
    var bestScore = -1 << 30;
    for (var letterIndex = 0; letterIndex < word.length; letterIndex++) {
      for (final entry in cells.entries) {
        if (entry.value != word[letterIndex]) continue;
        for (final horizontal in [true, false]) {
          final placement = _WordPlacement(
            word: word,
            row: entry.key.$1 - (horizontal ? 0 : letterIndex),
            column: entry.key.$2 - (horizontal ? letterIndex : 0),
            horizontal: horizontal,
          );
          final score = _placementScore(placement, cells, strict: strict);
          if (score == null || score <= bestScore) continue;
          best = placement;
          bestScore = score;
        }
      }
    }
    return best;
  }

  static int? _placementScore(
    _WordPlacement placement,
    Map<_WordCell, String> cells, {
    required bool strict,
  }) {
    final before = (
      placement.row - (placement.horizontal ? 0 : 1),
      placement.column - (placement.horizontal ? 1 : 0),
    );
    final after = (
      placement.row + (placement.horizontal ? 0 : placement.word.length),
      placement.column + (placement.horizontal ? placement.word.length : 0),
    );
    if (cells.containsKey(before) || cells.containsKey(after)) return null;

    var intersections = 0;
    var index = 0;
    for (final cell in placement.cells) {
      final existing = cells[cell];
      if (existing != null && existing != placement.word[index]) return null;
      if (existing != null) {
        intersections++;
      } else if (strict) {
        final neighbours = placement.horizontal
            ? <_WordCell>[(cell.$1 - 1, cell.$2), (cell.$1 + 1, cell.$2)]
            : <_WordCell>[(cell.$1, cell.$2 - 1), (cell.$1, cell.$2 + 1)];
        if (neighbours.any(cells.containsKey)) return null;
      }
      index++;
    }
    if (intersections == 0) return null;
    final distance = placement.row.abs() + placement.column.abs();
    return intersections * 1000 - distance * 3;
  }
}

class _WordCrosswordBoard extends StatelessWidget {
  final _WordCrossword crossword;
  final Set<String> foundWords;
  final bool nightMode;

  const _WordCrosswordBoard({
    required this.crossword,
    required this.foundWords,
    required this.nightMode,
  });

  @override
  Widget build(BuildContext context) {
    const cellSize = 31.0;
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: crossword.columns * cellSize,
          height: crossword.rows * cellSize,
          child: Stack(
            children: crossword.cells.entries.map((entry) {
              final related = crossword.cellWords[entry.key] ?? const {};
              final revealed = related.any(foundWords.contains);
              return Positioned(
                left: (entry.key.$2 - crossword.minColumn) * cellSize,
                top: (entry.key.$1 - crossword.minRow) * cellSize,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: cellSize - 2,
                  height: cellSize - 2,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: revealed
                        ? AppTheme.primaryPink
                        : nightMode
                        ? const Color(0xFF33445E)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: revealed
                          ? AppTheme.primaryPink
                          : const Color(0xFF8FA9D8),
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0x22000000), blurRadius: 2),
                    ],
                  ),
                  child: Text(
                    revealed
                        ? entry.value
                              .replaceAll('i', 'İ')
                              .replaceAll('ı', 'I')
                              .toUpperCase()
                        : '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _LetterWheelPainter extends CustomPainter {
  final List<String> letters;
  final List<Offset> points;
  final List<int> selected;
  final Offset? pointer;

  const _LetterWheelPainter({
    required this.letters,
    required this.points,
    required this.selected,
    required this.pointer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = AppTheme.primaryPink
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i < selected.length; i++) {
      canvas.drawLine(points[selected[i - 1]], points[selected[i]], line);
    }
    if (selected.isNotEmpty && pointer != null) {
      canvas.drawLine(points[selected.last], pointer!, line);
    }
    for (var i = 0; i < points.length; i++) {
      final active = selected.contains(i);
      canvas.drawCircle(
        points[i],
        29,
        Paint()..color = active ? AppTheme.primaryPink : Colors.white,
      );
      final text = TextPainter(
        text: TextSpan(
          text: letters[i],
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: active ? Colors.white : AppTheme.deepPurple,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, points[i] - Offset(text.width / 2, text.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _LetterWheelPainter oldDelegate) =>
      oldDelegate.selected.join(',') != selected.join(',') ||
      oldDelegate.letters.join() != letters.join() ||
      oldDelegate.pointer != pointer;
}
