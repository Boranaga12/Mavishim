# GitHub ile zorunlu APK güncelleme

Uygulama açılırken `Boranaga12/Mavishim` deposundaki en son GitHub Release kontrol edilir. Yayımlanan sürüm cihazdaki sürümden yeniyse uygulamanın geri kalanı açılmaz; APK indirilip Android'in kurulum ekranından güncellenmelidir.

Sürüm kontrolü internet bağlantısı veya GitHub hatası nedeniyle yapılamazsa uygulama menüsüne geçilmez ve tekrar deneme ekranı gösterilir. Böylece bağlantıyı kapatarak zorunlu güncellemeyi atlamak mümkün olmaz.

## Değişmemesi gerekenler

- `applicationId` her sürümde `com.mavishim.app` olarak kalmalı.
- Bütün APK'lar aynı release keystore ile imzalanmalı. `android/upload-keystore.jks` ve `android/key.properties` güvenli şekilde yedeklenmeli; kaybolursa mevcut kurulumun üzerine güncelleme yapılamaz.
- Uygulama kaldırılmamalı. Yeni APK mevcut uygulamanın üzerine kurulmalı. Böylece Hive, SharedPreferences ve secure storage verileri korunur.
- Keystore ve `key.properties` GitHub'a yüklenmemeli.

## Yeni sürüm yayımlama

1. `pubspec.yaml` içindeki sürümü artır. Örnek: `version: 1.0.1+2`. Artı işaretinden sonraki Android build numarası her yayında mutlaka büyümeli.
2. Release APK'yı üret:

   ```powershell
   flutter pub get
   flutter build apk --release
   ```

3. Oluşan `build/app/outputs/flutter-apk/app-release.apk` dosyasını `mavishim-v1.0.1+2.apk` gibi sürümü belirten bir adla kopyala.
4. GitHub'da **Releases > Draft a new release** sayfasına gir.
5. Etiketi tam sürümle oluştur: `v1.0.1+2`.
6. APK'yı Release dosyası olarak ekle, değişiklik notlarını yaz ve yayımla.
7. Önce kendi telefonunda eski sürümden güncellemeyi deneyerek verilerin kaldığını doğrula; sonra diğer kullanıcılara duyur.

## İlk dağıtım notu

Bu güncelleme kodunu içermeyen eski APK kendisini GitHub üzerinden güncelleyemez. Güncelleme altyapısını içeren ilk release APK bir defa elle kurulmalıdır. Bundan sonraki sürümler uygulama içinden zorunlu güncelleme ekranıyla alınır.

Android güvenlik nedeniyle APK'yı kullanıcı onayı olmadan sessizce kurdurmaz. İlk seferde tarayıcı/uygulama için **Bilinmeyen uygulamaları yükle** izni istenebilir. Kullanıcı kurulumu tamamlamazsa uygulama zorunlu güncelleme ekranında kalır.
