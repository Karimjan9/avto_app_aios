# Avto market — Flutter

Android va iOS uchun bitta Flutter ilovasi. Umumiy Dart kodi `lib/`, platforma loyihalari `android/` va `ios/` ichida. Ilova Flutter ekranlarini ishlatadi; saytni WebView yoki havola orqali ochmaydi. Marketplace sayti alohida `../platform` loyihasida qoladi.

Boshlang'ich ilova umumiy Laravel backenddan JSON API orqali kategoriya va e'lonlarni oladi. Rasmlar ham serverdan yuklanadi. Kategoriya filtri, yangilash va qayta urinish mavjud. Kirish, e'lon yaratish, chat va to'lov ekranlari hali qo'shilmagan.

## Windows muhiti

- Flutter **3.50.1**, Dart **3.14.0**.
- Microsoft OpenJDK **21**.
- Android SDK: API **36**, Build Tools **36.0.0**, NDK **28.2.13676358**, platform tools va emulator.
- VS Code: `Dart-Code.flutter`, `Dart-Code.dart-code`.
- Vositalar katalogi: `C:\x_programs\avto-toolchain` (`AVTO_TOOLCHAIN_HOME` bilan boshqa katalog tanlanadi).

`dev.ps1` kerakli `PATH`, `JAVA_HOME` va `ANDROID_HOME` qiymatlarini joriy terminal uchun tayyorlaydi. Foydalanuvchi muhitidagi yangi yo'llarni ko'rish uchun VS Code va terminalni qayta oching.

Yangi Windows kompyuterida Git va VS Code o'rnatilgach, `app` ichida:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup-windows.ps1
```

Skript `toolchain.windows.json` dagi versiyalarni o'rnatadi, JDK/Android arxivlarining SHA-256 summalarini va Flutter Git commitini tekshiradi. Android SDK paketlari va `Avto_API_36` virtual qurilmasini tayyorlaydi. Mavjud vositalardan qayta foydalanadi.

## Android ilovasini ishga tushirish

VS Code'da ushbu loyiha papkasini yoki umumiy `Avto.code-workspace` ni oching. Avval `App: Android emulator` vazifasini ishga tushiring. Android ochilgach, `Avto: Android + server backend` konfiguratsiyasini tanlab `F5` bosing. Ilova emulator ichiga o'rnatiladi va Flutter debugger ulanadi. Ishga tushirish vazifalari `.vscode/tasks.json` bilan repozitoriyda saqlanadi.

PowerShell orqali `app` papkasidan:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\dev.ps1 emulator
powershell -NoProfile -ExecutionPolicy Bypass -File .\dev.ps1 devices
powershell -NoProfile -ExecutionPolicy Bypass -File .\dev.ps1 android -Device emulator-5554
```

`emulator-5554` o'rniga `devices` ko'rsatgan identifikatorni ishlating. USB debugging yoqilgan haqiqiy Android telefon ham qurilmalar ro'yxatida ko'rinadi.

`Avto_API_36` AOSP emulatori 720×1560 ekran va 2.5 GB RAM bilan sozlangan. Birinchi yuklanish bir necha daqiqa olishi mumkin. Google Play xizmatlari kerak bo'ladigan funksiyalar uchun keyinchalik Google APIs tizim rasmi bilan ham sinov o'tkaziladi.

## Tekshirish va APK

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\dev.ps1 doctor
powershell -NoProfile -ExecutionPolicy Bypass -File .\dev.ps1 check
powershell -NoProfile -ExecutionPolicy Bypass -File .\dev.ps1 backend
powershell -NoProfile -ExecutionPolicy Bypass -File .\dev.ps1 apk
```

APK: `build/app/outputs/flutter-apk/app-debug.apk`. Bu ishlab chiqish uchun debug APK. Unit/widget testlar soxta HTTP transportidan foydalanadi. `backend` buyrug'i haqiqiy serverga faqat o'qish so'rovlarini yuboradi.

## Backend tanlash

Standart API: `https://platform.buxoroavto.uz/api/v1`.

- `config/production.json` — serverdagi backend.
- `config/local-android.json` — Android emulatori uchun `http://10.0.2.2:8001/api/v1`.

Lokal Laravel serveri `8001` portda ishlayotganda:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\dev.ps1 android -Device emulator-5554 -ApiBaseUrl http://10.0.2.2:8001/api/v1
```

Backend manzili ilova ichida veb sahifa ochish uchun ishlatilmaydi. API ma'lumotlarni JSON ko'rinishida beradi, interfeysni Flutter chizadi. Ilova bazaga bevosita ulanmaydi. SSH, baza parollari va boshqa maxfiy kalitlar ilovaga kiritilmaydi.

## iOS

`ios/` loyihasi va `codemagic.yaml` tayyor. Kod Windows'da yoziladi; iOS build va simulator uchun macOS/Xcode muhiti kerak. Bu mahalliy Mac yoki bulutdagi macOS mashinasi bo'lishi mumkin.

Codemagic akkaunti hali ulanmagan, shu sababli haqiqiy iOS build va simulator sinovi bajarilmadi. Tartib: [docs/ios-cloud.md](docs/ios-cloud.md).

## Avval bajarilgan tekshiruvlar

2026-11-25 kuni Windows'da `flutter doctor`, `flutter analyze` va 4 ta unit/widget test muvaffaqiyatli o'tdi. Android debug APK yig'ilib, `Avto_API_36` emulatoriga o'rnatildi; haqiqiy backenddagi e'lonlar, rasmlar va kategoriya filtri tekshirildi. Serverga SSH ulanishi va API holati faqat o'qish amallari bilan tekshirildi. Bu natijalar o'sha paytdagi kodga tegishli; keyingi o'zgarishlardan so'ng `dev.ps1 check` va Android sinovini qayta bajaring.

## Tuzilma

- `lib/main.dart` — Flutter marketplace ekranlari.
- `lib/marketplace_api.dart` — umumiy API mijozi va javob modellari.
- `test/marketplace_test.dart` — API va ekran holatlari testlari.
- `android/`, `ios/` — mobil platforma loyihalari.
- `dev.ps1`, `scripts/` — Windows muhitini sozlash va ishga tushirish buyruqlari.
- `.vscode/` — SDK, Android debug va kengaytma sozlamalari.
- `codemagic.yaml` — Android tekshiruvlari va unsigned iOS simulator build.

Manbalar: [Flutter Android sozlash](https://docs.flutter.dev/platform-integration/android/setup), [Flutter iOS sozlash](https://docs.flutter.dev/platform-integration/ios/setup).
