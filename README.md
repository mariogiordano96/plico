# Plico

App Flutter per la gestione del piano alimentare e il tracciamento macronutrienti.

---

## Build Android

### APK debug (test rapido)
```bash
flutter build apk --debug
# output: build/app/outputs/flutter-apk/app-debug.apk
```

### APK release (da installare manualmente)
```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

### App Bundle release (per il Play Store)
```bash
flutter build appbundle --release
# output: build/app/outputs/bundle/release/app-release.aab
```

### Installazione diretta su device Android collegato
```bash
flutter run --release
```

---

## Build iOS (richiede Mac + Xcode)

### Prima di buildare (una tantum o dopo nuove dipendenze)
```bash
cd ios
pod install
cd ..
```

### Build debug su simulatore
```bash
flutter run -d "iPhone 16"    # sostituire con il nome del simulatore disponibile
```

### Build release IPA (per TestFlight / App Store)
```bash
flutter build ipa --release
# output: build/ios/ipa/plico.ipa
```

### Aprire il progetto in Xcode
```bash
open ios/Runner.xcworkspace
```

> **Nota:** usare sempre `Runner.xcworkspace` e non `Runner.xcodeproj`.

---

## Aggiornamento schema Isar (dopo modifiche ai modelli)

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Dipendenze

```bash
flutter pub get
```
