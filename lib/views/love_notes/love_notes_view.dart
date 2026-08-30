import 'dart:math';

import 'package:flutter/material.dart';
import '../../widgets/glass_card.dart';
import '../../core/theme/app_theme.dart';

class LoveNotesView extends StatefulWidget {
  const LoveNotesView({super.key});

  @override
  State<LoveNotesView> createState() => _LoveNotesViewState();
}

class _LoveNotesViewState extends State<LoveNotesView> {
  final List<String> _loveNotes = [
    'Seni her gün bir öncekinden daha çok seviyorum 💖',
    'Gülüşün benim en sevdiğim manzaradır 🌸',
    'Seninle geçirdiğim her an benim için bir armağandır 🎁',
    'Hayatımın en güzel hikayesi sensin ✨',
    'Yorulursan sırtını bana yasla, ben hep buradayım 🫂',
    'Dünyadaki tüm papatyalar senin güzelliğini kıskanır 🌼',
    'Sen benim en huzurlu limanımsın ⚓',
    'Kalbinin güzelliği yüzüne yansıyor, iyi ki varsın 🌟',
    'Seninle kahve içmek bile dünyanın en tatlı aktivitesi ☕',
    'Birlikte yaşlanmak istediğim tek kişisin 💍',
    'Varlığın, en sıradan günü bile özel kılıyor 💙',
    'Bugün de kendine nazik davranmayı hak ediyorsun 🌷',
    'Senin yanında içim sakinleşiyor, iyi ki varsın 🌙',
    'Küçük adımların bile çok değerli; seninle gurur duyuyorum ✨',
    'Gözlerin güldüğünde dünya biraz daha güzel oluyor 😊',
    'Yorulduğunda dinlenmek de ilerlemektir; sana alan açıyorum 🫂',
    'Senin sesin, günümün en sevdiğim melodisi 🎶',
    'Her halinle sevilesi ve değerlisin 🌸',
    'Birlikte kurduğumuz hayaller kalbimin en güzel köşesinde 💭',
    'Bugün kendine söylediğin güzel bir söz, yarınını da aydınlatır ☀️',
    'Seninle aynı takımda olmak benim en sevdiğim şey 🤝',
    'İçindeki ışık, zor günlerde bile yolunu bulur 🌟',
    'Kendini kıyaslama; sen kendi hikâyenin eşsiz kahramanısın 🦋',
    'Bir fincan kahve, bir sarılma ve sen: mükemmel üçlü ☕',
    'Hissettiklerin geçerli; onları taşırken yalnız değilsin 💌',
    'Bugün nefes al, yavaşla ve kendine güven 🌿',
    'Başardığın küçük şeyleri de kutlamayı unutma 🎈',
    'Sen gülünce ev gibi hissediyorum 🏡',
    'Kalbinin şefkati çevrendeki herkese iyi geliyor 💖',
    'Her gün yeniden seçerdim seni, hiç düşünmeden 💍',
    'Bugün yapabildiğinin en iyisi yeterli; sen yeterlisin 🌼',
    'Yanında susmak bile güzel bir sohbet gibi 🤍',
    'İyi hissetmek için acele etmek zorunda değilsin 🌊',
    'Güçlü olduğun kadar hassas olman da çok güzel 🪻',
    'Seninle paylaşacağım daha çok kahkaha var 😄',
    'Kendine verdiğin her değer, içindeki baharı büyütür 🌱',
    'Bugün aynada gördüğün kişiye sevgiyle bak ✨',
    'Ellerini tuttuğumda tüm telaşım yavaşlıyor 🤍',
    'Bize ait küçük anılar, en kıymetli hazinem 💎',
    'Senin mutluluğun benim için her zaman önemli 💙',
    'Gece ne kadar uzun olursa olsun, sabah mutlaka gelir 🌅',
  ];

  late String _todaysNote;

  @override
  void initState() {
    super.initState();
    _todaysNote = _loveNotes[DateTime.now().day % _loveNotes.length];
  }

  void _getNewRandomNote() {
    if (_loveNotes.length < 2) return;
    final alternatives = _loveNotes
        .where((note) => note != _todaysNote)
        .toList();
    setState(() {
      _todaysNote = alternatives[Random().nextInt(alternatives.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.pageBackground(context),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sevgi Notları & Olumlamalar 💌',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sana özel hazırlanmış tatlı mesajlar.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // Main Today Note Card
                Expanded(
                  flex: 5,
                  child: GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.mark_email_read,
                                  color: AppTheme.primaryPink,
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Günün Sevgi Notu',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryPink,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: AppTheme.primaryPink,
                              ),
                              onPressed: _getNewRandomNote,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '“ $_todaysNote ”',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text(
                            'Başka Not Çek 🎲',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPink,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _getNewRandomNote,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Sweet Quote Banner
                Expanded(
                  flex: 3,
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppTheme.accentPeach,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Günün Olumlaması ✨',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Sen her halinle çok değerlisin ve mükemmelsin. Bugün kendine gülümsemeyi unutma! 😊💖',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
