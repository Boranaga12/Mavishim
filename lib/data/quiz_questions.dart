// ON U NE KADAR TANIYORSUN? - ÖZEL SORU LİSTESİ
//
// Her soru için 4 seçenek ve doğru cevabın indeks sırası (0, 1, 2 veya 3) tanımlanmıştır.

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({
    required this.question,
    required List<String> options,
    required int correctIndex,
  }) : options = List.unmodifiable(options),
       correctIndex = options.isEmpty
           ? 0
           : correctIndex.clamp(0, options.length - 1).toInt();

  QuizQuestion copyWith({int? correctIndex}) => QuizQuestion(
    question: question,
    options: options,
    correctIndex: correctIndex ?? this.correctIndex,
  );

  Map<String, dynamic> toMap() => {
    'question': question,
    'options': options,
    'correctIndex': correctIndex,
  };

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    final rawOptions = map['options'];
    return QuizQuestion(
      question: map['question'] as String? ?? '',
      options: rawOptions is List
          ? rawOptions.whereType<String>().toList()
          : const [],
      correctIndex: map['correctIndex'] as int? ?? 0,
    );
  }
}

final List<QuizQuestion> customQuizQuestions = List.unmodifiable([
  QuizQuestion(
    question: 'O hangi yemeği yemeyi daha çok sever?',
    options: [
      'Ev Yapımı Pizza 🍕',
      'Elifini 💖',
      'İskender Kebap 🥩',
      'Kremalı Makarna 🍝',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'O hangi içeceği gün içinde daha çok tüketir?',
    options: [
      'Demleme Çay ☕',
      'Soğuk Kahve 🧊',
      'Elifinin sütünü 🥛',
      'Taze Portakal Suyu 🍊',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'O hangi tatlıyı asla geri çeviremez?',
    options: [
      'Elifinin bal damlayan dudakları 💋',
      'Fıstıklı Baklava 🥮',
      'Sıcak Sufle 🍫',
      'San Sebastian Cheesecake 🍰',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    question: 'O boş zamanlarında hangi aktiviteyi yapmayı daha çok sever?',
    options: [
      'Bilgisayar Oyunu Oynamak 🎮',
      'Spor Yapmak 🏋️',
      'Kitap Okumak 📚',
      'Elifiyle ilgilenmek 🌸',
    ],
    correctIndex: 3,
  ),
  QuizQuestion(
    question: 'O hangi tür filmleri/dizileri izlemeyi daha çok sever?',
    options: [
      'Aksiyon ve Macera 💥',
      'Elifinin rüya sekansı 🎬',
      'Bilim Kurgu 🚀',
      'Korku ve Gerilim 👻',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'O hangi müzik türünü dinlemeyi daha çok sever?',
    options: [
      'Türkçe Pop 🎵',
      'Yabancı Rock 🎸',
      'Elifinin sesini 🎶',
      'Akustik Gitar 🎼',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'O evde vakit geçirirken hangisini yapmayı daha çok sever?',
    options: [
      'Elifiyle fantezileşmek 🤪',
      'Temizlik Yapmak 🧹',
      'Uyumak 😴',
      'Televizyon İzlemek 📺',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    question: 'O günün hangi diliminde kendini daha enerjik hisseder?',
    options: [
      'Erken Sabah Saatlerinde 🌅',
      'Öğle Sıcağında ☀️',
      'Gece Yarısında 🌙',
      'Elifiyle birlikteyken ⚡',
    ],
    correctIndex: 3,
  ),
  QuizQuestion(
    question: 'O telefonda en çok hangi uygulamada vakit geçirir?',
    options: [
      'Instagram Reels 📸',
      'Elifiyle konuştuğu uygulama 📱',
      'YouTube Videosu 📹',
      'Clash Royale 🎮',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'O dinlenmek istediğinde hangisini yapmayı daha çok sever?',
    options: [
      'Müzik Dinlemek 🎧',
      'Yürüyüş Yapmak 🚶',
      'Elifiyle sarılarak uyumak 🛌',
      'Sıcak Banyo Yapmak 🛁',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'O tatilde nasıl bir yere gitmeyi daha çok sever?',
    options: [
      'Elifinin yanına ✈️',
      'Sakin Bir Sahil Kasabası 🏖️',
      'Doğa İçi Dağ Evi 🏔️',
      'Tarihi Şehir Turu 🏛️',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    question: 'O en çok hangi mevsimi sever?',
    options: [
      'Sıcak Yaz Günleri ☀️',
      'Karlı Kış Geceleri ❄️',
      'Elifiyle Olan Mevsimleri 🌸',
      'Yağmurlu Sonbaharı 🍂',
    ],
    correctIndex: 3,
  ),
  QuizQuestion(
    question: 'O dışarı çıktığında nasıl mekanlarda oturmayı daha çok sever?',
    options: [
      'Kalabalık Restoranlar 🍔',
      'Elifiyle yalnız olduğu mekanlarda ☕',
      'Sakin Kahve Dükkanları ☕',
      'Açık Hava Parkları 🌳',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'O hangi kokuyu koklamayı daha çok sever?',
    options: [
      'Taze Kahve Kokusu ☕',
      'Yağmur Sonrası Toprak Kokusu 🌧️',
      'Elifinin kokusu 🌸',
      'Vanilya Parfümü 🕯️',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'O en çok hangi sesi duymak ister?',
    options: [
      'Elifinin gülüşü 😊',
      'Dalga Sesleri 🌊',
      'Kuş Cıvıltıları 🐦',
      'Yağmur Damlaları 🌧️',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    question: 'O en çok hangi manzarayı izlemeyi sever?',
    options: [
      'Deniz Batımı Manzarası 🌅',
      'Gece Şehir Işıkları 🏙️',
      'Yıldızlı Gökyüzü 🌌',
      'Elifinin gözleri 👀',
    ],
    correctIndex: 3,
  ),
  QuizQuestion(
    question: 'O stresli olduğunda ne yapmak ona iyi gelir?',
    options: [
      'Yalnız Kalmak 🤫',
      'Elifiyle sarılmak 🫂',
      'Derin Nefes Almak 🧘',
      'Papatya Çayı İçmek 🍵',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'O dünyadaki en safe yer neresi der?',
    options: [
      'Kendi Çocukluk Odası 🛏️',
      'Doğadaki Sakin Bir Orman 🌲',
      'Elifinin yanı 🏡',
      'Evdeki Koltuğu 🛋️',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'O sabahları uyanmak için en çok neye ihtiyaç duyar?',
    options: [
      'Elifinden gelen günaydın mesajına 📲',
      'Sert Bir Filtre Kahveye ☕',
      'Yüksek Sesli Alarma ⏰',
      'Soğuk Suya 💦',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    question: 'O yorulduğunda pilini en hızlı ne şarj eder?',
    options: [
      '8 Saat Uykusunu Almak 💤',
      'Enerji İçeceği ⚡',
      'Elifinin tatlı bir sözü 💬',
      'Sessizce Uzanmak 🛌',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'O hayatında en çok neyi tutmak ister?',
    options: [
      'Elifinin elini 🤝',
      'Direksiyonu 🚘',
      'Kendi İşini 💼',
      'Kendi Özgürlüğünü 🕊️',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    question: 'O en çok hangi bildirimi görmeyi sever?',
    options: [
      'Banka Hesap Bildirimini 💰',
      'Elifinden gelen mesajı 💌',
      'Sosyal Medya Beğenisini 👍',
      'İndirim Bildirimini 🏷️',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'O hangi ilacı her derde deva görür?',
    options: [
      'Ağrı Kesici 💊',
      'Nane Limon Çayı 🍋',
      'Elifinin öpücüğü 💋',
      'C Vitamini 🍊',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'O kışın ısınmak için neye sarılır?',
    options: [
      'Elifinin göbüşüne 🔥',
      'Kalın Polar Battaniyeye 🧶',
      'Elektrikli Sobaya ♨️',
      'Yün Çoraplara 🧦',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    question: 'O hangi fotoğrafa bakmaktan bıkmaz?',
    options: [
      'Manzara Fotoğraflarına 🏔️',
      'Kendi Çocukluk Fotoğrafına 👶',
      'Elifinin bir pikselinin bulunduğu herhangi bir fotoğrafa 📸',
      'Araba Fotoğraflarına 🏎️',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'O en çok hangi hediyeyi almak ister?',
    options: [
      'Elifinin varlığı 🎁',
      'Son Model Telefon 📱',
      'Pahalı Bir Saat ⌚',
      'Marka Kıyafetler 👕',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    question: 'O ne zaman kendini eksik hisseder?',
    options: [
      'Cüzdanı Boşken 💸',
      'Elifinden uzak kaldığında 💔',
      'Karnı Açken 🍔',
      'İnterneti Bittiğinde 🌐',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'O gece yatmadan önce en son neyi düşünür?',
    options: [
      'Yarın Yapılacak İşleri 📝',
      'Günün Yorgunluğunu 🥱',
      'Elifiyle kurduğu hayalleri 💭',
      'İzlediği Filmi 🍿',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'O en çok hangi kelimeyi söylemeyi sever?',
    options: ['Elifim 🗣️', 'Aynen 💬', 'Fark Etmez 🤷', 'Hallederiz 👍'],
    correctIndex: 0,
  ),
  QuizQuestion(
    question: 'O başı ağrıdığında en iyi gelen şey nedir?',
    options: [
      'Karanlık Odada Uyumak 🛌',
      'Elifinin bacağına yatmak 💆‍♂️',
      'Soğuk Kompleks 🧊',
      'Ağrı Kesici Hap 💊',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'O yağmur yağdığında ne yapmak ister?',
    options: [
      'Pencereden Kahve İçerek İzlemek ☕',
      'Evde Film Açıp İzlemek 🍿',
      'Elifiyle aynı şemsiyeyi paylaşmayı ☂️',
      'Sıcak Çorba İçmek 🥣',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'O geleceğe dair en büyük hedefini ne olarak görür?',
    options: [
      'Elifiyle bir geleceği 💍',
      'Çok Zengin Olmak 💵',
      'Dünya Turuna Çıkmak 🌍',
      'Kendi Şirketini Kurmak 🏢',
    ],
    correctIndex: 0,
  ),
]);
