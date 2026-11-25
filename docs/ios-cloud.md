# Windows'dan iOS'ni bulutda tekshirish

Kod Windows'da VS Code va Flutter orqali yoziladi. iOS ilovasini yig'ish bulutdagi macOS mashinasida bajariladi. `codemagic.yaml` aynan Flutter **3.50.1** versiyasini ishlatadi.

## Codemagic

1. Ushbu `app` loyihasini Git repozitoriysi ildizi sifatida joylashtiring. `codemagic.yaml` uning ildizida bo'lishi kerak. Butun `Avto` papkasini monorepo sifatida joylashtirsangiz, workflow'ning ish katalogi va konfiguratsiya yo'lini shunga moslang.
2. Codemagic hisobida o'sha repozitoriyni ulang.
3. YAML workflow sifatida `ios-simulator` ni tanlang.
4. Workflow paketlarni oladi, `flutter analyze` va `flutter test` ni bajaradi, so'ng iOS simulator uchun unsigned ilovani yig'adi.
5. Natijalar `build/ios/iphonesimulator/Runner.app` va `Runner-simulator.zip` bo'ladi.

Bu simulator build uchun Apple signing sertifikati yoki App Store Connect kaliti kerak emas. `.app` yoki ZIP faylni haqiqiy iPhone'ga to'g'ridan-to'g'ri o'rnatib bo'lmaydi. Haqiqiy iPhone/TestFlight tarqatishiga alohida signed build va tegishli Apple hisob sozlamalari kerak bo'ladi.

## Windows brauzerida interaktiv sinov

Codemagic App Preview mos `.app` artifact yonida **Quick Launch** tugmasini beradi. U orqali Windows'dagi Chrome ichida bulut iOS simulatorini boshqarish mumkin. Joriy xizmatda App Preview jamoa akkauntlari va tegishli pullik rejaga bog'liq; sinov daqiqalari tugagach foydalanish pullik bo'ladi. Oddiy CI build va interaktiv preview alohida imkoniyatlardir.

Muqobil yo'l: `Runner-simulator.zip` ni Appetize'ga yuklash. Unga simulator `.app` arxivi kerak; App Store uchun `.ipa` mos kelmaydi. Yuklashdan oldin xizmat qo'llaydigan simulator arxitekturasini tekshiring.

Kod o'zgargach, yangi build tayyorlanadi. Bu Windows'da mahalliy iOS simulatori yoki doimiy hot reload o'rnini to'liq bosmaydi. Yakuniy relizni haqiqiy iPhone'da ham tekshiring.

## Ushbu workspace holati

Cloud konfiguratsiyasi lokal tayyorlangan. Codemagic/Appetize akkaunti ulanmagan bo'lsa, bulut build va interaktiv iOS sinovi bajarilgan hisoblanmaydi. Repozitoriyga maxfiy SSH yoki server `.env` fayllarini qo'shmang.

Manbalar: [Codemagic App Preview](https://docs.codemagic.io/flutter-distributing/app-preview/), [iOS simulator build](https://docs.codemagic.io/yaml-code-signing/ios-simulator-builds/), [Appetize iOS](https://docs.appetize.io/platform/app-management/uploading-apps/ios), [Flutter iOS](https://docs.flutter.dev/platform-integration/ios/setup).
