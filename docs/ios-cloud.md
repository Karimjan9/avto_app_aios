# iOS ilovasini yig'ish va tekshirish

`ios/` — umumiy Flutter kodidan haqiqiy iOS ilovasi yig'iladigan platforma loyihasi. Ilova Flutter ekranlarini ishlatadi va Laravel backendga JSON API orqali ulanadi.

Kod Windows'da VS Code orqali yoziladi. iOS'ni yig'ish va simulatorni ishlatish uchun macOS va Xcode kerak; Windows'dagi VS Code kengaytmasi bu muhitni almashtirmaydi.

## Mac mavjud bo'lsa

Mac'da Flutter **3.50.1**, Xcode va Flutter iOS sozlamalarini tayyorlang. `app` loyihasi ildizidan:

```bash
flutter pub get
flutter doctor -v
open -a Simulator
flutter devices
flutter run --dart-define-from-file=config/production.json
```

Bir nechta qurilma bo'lsa, `flutter run` ga `-d <device-id>` qo'shing. Mac'da `.vscode/settings.json` ichidagi `dart.flutterSdkPath` ni o'sha kompyuterdagi Flutter SDK manziliga moslang. VS Code'da iOS simulatorini qurilma sifatida va `Avto: iOS + server backend (macOS)` konfiguratsiyasini tanlab `F5` bosing.

## Windows uchun bulutdagi macOS build

Repozitoriy ildizidagi `codemagic.yaml` Flutter **3.50.1** uchun tayyorlangan.

1. Codemagic akkauntini oching va `app` repozitoriysini ulang. `codemagic.yaml` repozitoriy ildizida bo'lishi kerak.
2. `ios-simulator` YAML workflow'ini tanlang.
3. Workflow paketlarni oladi, `flutter analyze` va `flutter test` ni bajaradi, so'ng iOS simulator uchun unsigned ilovani yig'adi.
4. Natijalar `build/ios/iphonesimulator/Runner.app` va `Runner-simulator.zip` bo'ladi.

Simulator build Apple signing sertifikatisiz yig'iladi. `.app` yoki ZIP faylni Windows'da yoki haqiqiy iPhone'da bevosita ishga tushirib bo'lmaydi; unga macOS iOS simulatori kerak. Haqiqiy iPhone/TestFlight tarqatishi uchun alohida signed build va Apple hisob sozlamalari zarur.

## Hozirgi holat

iOS loyiha va bulut konfiguratsiyasi tayyor. Mac va Codemagic akkaunti ulanmagani sabab haqiqiy iOS build hamda simulator sinovi hali bajarilmadi. Android sinovi iOS sinovi o'rnini bosmaydi. Repozitoriyga server `.env`, SSH yoki signing maxfiy kalitlarini qo'shmang.

Manbalar: [Flutter iOS sozlash](https://docs.flutter.dev/platform-integration/ios/setup), [Codemagic iOS simulator build](https://docs.codemagic.io/yaml-code-signing/ios-simulator-builds/).
