# Avto market — Flutter

Android va iOS uchun bitta Flutter loyihasi. Umumiy kod `lib/`, platforma sozlamalari `android/` va `ios/` ichida. Oldingi bo'sh `aios/` papkasi Flutter talab qiladigan `ios/` nomiga almashtirildi. `web/` Windows'da tezkor preview uchun; asosiy marketplace web interfeysi `../platform` ichida qoladi.

Boshlang'ich ilova haqiqiy backenddan kategoriya va e'lonlarni o'qiydi. Kategoriya filtri, yangilash, bo'sh holat va ulanish xatosidan keyin qayta urinish mavjud. Bu to'liq marketplace mobil relizi emas; kirish, e'lon yaratish, chat va to'lov ekranlari keyingi ishlar.

## Windows muhiti

- Flutter **3.50.1**, Dart **3.14.0**.
- Microsoft OpenJDK **21**.
- Android SDK: API **36**, Build Tools **36.0.0**, NDK **28.2.13676358**, platform tools va emulator.
- VS Code: `Dart-Code.flutter`, `Dart-Code.dart-code`.
- Vositalar katalogi: `C:\x_programs\avto-toolchain` (`AVTO_TOOLCHAIN_HOME` bilan boshqa katalog tanlanadi).

`dev.ps1` kerakli `PATH`, `JAVA_HOME` va `ANDROID_HOME` qiymatlarini joriy terminal uchun o'zi tayyorlaydi. Windows foydalanuvchisi muhitiga ham yo'llar qo'shilgan. Yangi sozlamalarni oddiy terminal va VS Code ko'rishi uchun ularni qayta ochish mumkin.

Yangi Windows kompyuterida Git va VS Code o'rnatilgach, vositalarning aniq versiyalarini `toolchain.windows.json` dan olib o'rnatish mumkin:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup-windows.ps1
```

Skript JDK/Android arxivlarining SHA-256 summalarini va Flutter Git commitini tekshiradi. Android SDK paketlari o'rnatiladi va `Avto_API_36` virtual qurilmasi yaratiladi. Vositalar avval o'rnatilgan bo'lsa, ulardan qayta foydalanadi.

## Ishga tushirish

`app` papkasida PowerShell orqali:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\dev.ps1 web
```

Chrome preview va serverdagi backend ishlatiladi. Manzil: `http://127.0.0.1:8085`. VS Code'da `Avto.code-workspace` ni oching va `Avto: Chrome + server backend` konfiguratsiyasi bilan `F5` bosing.

Android emulator va ilova:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\dev.ps1 emulator
powershell -NoProfile -ExecutionPolicy Bypass -File .\dev.ps1 devices
powershell -NoProfile -ExecutionPolicy Bypass -File .\dev.ps1 android -Device emulator-5554
```

AVD nomi `Avto_API_36`. Bu AOSP simulatori; Google Play xizmatlari yo'q. FCM yoki Google Maps ulanadigan bosqichda Google APIs tizim rasmi bilan ham alohida sinov kerak bo'ladi. `emulator-5554` o'rniga `devices` buyrug'i ko'rsatgan identifikator ishlatiladi.

Emulator 720×1560 ekran va 2.5 GB RAM bilan sozlangan. Birinchi yuklanish ushbu kompyuterda bir necha daqiqa olishi mumkin; Android to'liq ochilgach ilovani ishga tushiring. Dastlab ulanish xatosi ko'rinsa, `Qayta urinish` tugmasini bosing.

## Tekshirish va APK

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\dev.ps1 doctor
powershell -NoProfile -ExecutionPolicy Bypass -File .\dev.ps1 check
powershell -NoProfile -ExecutionPolicy Bypass -File .\dev.ps1 backend
powershell -NoProfile -ExecutionPolicy Bypass -File .\dev.ps1 apk
```

APK: `build/app/outputs/flutter-apk/app-debug.apk`. Bu ishlab chiqish uchun debug APK. Testlar serverga ma'lumot yozmaydi; unit/widget testlar soxta HTTP transportidan foydalanadi. `backend` buyrug'i esa haqiqiy serverga faqat o'qish so'rovlarini yuboradi.

## Backend tanlash

Standart API: `https://platform.buxoroavto.uz/api/v1`.

- `config/production.json` — serverdagi backend.
- `config/local-web.json` — Chrome uchun `http://127.0.0.1:8001/api/v1`.
- `config/local-android.json` — Android emulatori uchun `http://10.0.2.2:8001/api/v1`.

Masalan, lokal Laravel serveri `8001` portda ishlayotganda:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\dev.ps1 android -Device emulator-5554 -ApiBaseUrl http://10.0.2.2:8001/api/v1
```

Flutter qurilmalari Laravel bazasiga to'g'ridan-to'g'ri ulanmaydi; barcha so'rovlar API orqali o'tadi. Bu JSON fayllarida faqat ochiq konfiguratsiya saqlanadi. SSH, baza va boshqa maxfiy kalitlar ilovaga kiritilmaydi.

## iOS

`ios/` loyihasi va `codemagic.yaml` tayyorlandi. Windows'da iOS native build bajarilmaydi; bulutdagi macOS workflow ishlatiladi. Codemagic akkaunti hali ulanmagan, shu sababli haqiqiy iOS build va simulator sinovi bajarilmadi. To'liq tartib: [docs/ios-cloud.md](docs/ios-cloud.md).

## Bajarilgan tekshiruvlar

2026-11-25 kuni Windows'da `flutter doctor` muammosiz, `flutter analyze` xatosiz va 4 ta unit/widget test muvaffaqiyatli o'tdi. Chrome desktop/mobil o'lchamlarda serverdagi e'lonlar, rasmlar va kategoriya filtri tekshirildi. Android debug APK yig'ildi, `Avto_API_36` emulatoriga o'rnatildi; haqiqiy backenddagi e'lonlar, rasmlar va kategoriya filtri tekshirildi. Serverga SSH orqali ulanish hamda API holati faqat o'qish amallari bilan tekshirildi.

## Tuzilma

- `lib/main.dart` — boshlang'ich marketplace interfeysi.
- `lib/marketplace_api.dart` — umumiy API mijozi va javob modellari.
- `test/marketplace_test.dart` — API shartnomasi va ekran holatlari.
- `dev.ps1`, `scripts/` — Windows ishga tushirish va tekshirish buyruqlari.
- `.vscode/` — VS Code uchun SDK, debug va kengaytma sozlamalari.
- `codemagic.yaml` — Android tekshiruvlari va unsigned iOS simulator build.

Flutter sozlash manbalari: [Windows/VS Code](https://docs.flutter.dev/install/with-vs-code), [Android](https://docs.flutter.dev/platform-integration/android/setup), [iOS](https://docs.flutter.dev/platform-integration/ios/setup).
