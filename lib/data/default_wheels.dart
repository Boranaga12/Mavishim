import '../models/wheel_model.dart';

final List<WheelModel> defaultWheels = List.unmodifiable([
  WheelModel(
    id: 'dinner_wheel',
    title: 'Akşam Ne Yesek? 🍕',
    iconName: 'utensils',
    options: [
      'Ev Yapımı Makarna 🍝',
      'Lezzetli Pizza 🍕',
      'Ev Yapımı Mantı 🥟',
      'Çıtır Hamburger 🍔',
      'Fırında Köfte Patates 🍲',
      'Taze Balık & Salata 🐟',
      'Izgara Tavuk & Pilav 🍗',
      'Zeytinyağlı Sebze 🥗',
      'Mercimek Çorbası & Tost 🥣',
      'Menemen & Sıcak Ekmek 🍳',
      'Kıymalı Patates Oturtma 🥔',
      'Fırında Tavuk Sebze 🍗',
      'Nohut & Pirinç Pilavı 🫘',
      'Kuru Fasulye & Pilav 🍚',
      'Sebzeli Bulgur Pilavı 🥕',
      'Ev Usulü Tavuk Sote 🍲',
      'Kıymalı Ispanak 🥬',
      'Kaşarlı Gözleme 🫓',
      'Patatesli Omlet 🥚',
      'Tarhana Çorbası & Börek 🥣',
      'Sivas Etli Ekmek 🫓',
      'Sivas Hingel Mantısı 🥟',
      'Sivas Madımak Yemeği 🌿',
      'Sivas Divriği Pilavı 🍚',
      'Sivas Katmeri 🫓',
      'Sivas Peskütan Çorbası 🥣',
      'Sivas Sübüra Yemeği 🍲',
      'Sivas İçli Köfte 🍽️',
    ],
  ),
  WheelModel(
    id: 'planner_wheel',
    title: 'Günün Verimli Planı 🧘‍♀️',
    iconName: 'planner',
    options: [
      '15 Dk Eğlenceli Oyun 🎮',
      '30 Dk Spor & Egzersiz 🧘‍♀️',
      '30 Dk Evi Toparlama 🧹',
      '30 Dk Resim Çizme 🎨',
      '20 Dk Kitap Okuma 📚',
      '15 Dk Yürüyüş 🚶‍♀️',
      '20 Dk Cilt Bakımı 🌸',
    ],
  ),
]);

WheelModel refreshBuiltInWheelOptions(WheelModel wheel) {
  WheelModel? latest;
  for (final candidate in defaultWheels) {
    if (candidate.id == wheel.id) {
      latest = candidate;
      break;
    }
  }
  if (latest == null || wheel.isCustom) return wheel;
  final options = [...wheel.options];
  for (final option in latest.options) {
    if (!options.contains(option)) options.add(option);
  }
  return wheel.copyWith(title: latest.title, options: options);
}
