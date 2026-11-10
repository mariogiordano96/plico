# Plico — open source workout and nutrition tracker for Android

Free, open source (GPL-3.0) **Android app for gym training and diet tracking**: food diary and
calorie/macro counter, meal-plan generator, workout plans with progression, body-composition
(skinfold) tracking and an optional AI coach. Built with Flutter.

A privacy-friendly, offline-first alternative to apps like MyFitnessPal, Yazio, Hevy or Strong:
**no account, no ads, no analytics, no backend** — your data stays on your device (Isar database).
Includes the Italian **CREA** food-composition database, plus Open Food Facts search and barcode scanning.

<!-- TODO: add screenshots (docs/screenshots/*.png) -->

> **License:** [GNU GPL v3.0](LICENSE). Copyright (C) 2026 maxio96 (Mario Giordano).
> You may use, study, modify and redistribute Plico, but any distributed version (modified or not)
> must keep this copyright notice and be released under the same license, with its source code.
> The name "Plico" and its logo are not covered by the license: please pick a different name and
> icon for your own fork. See [NOTICE.md](NOTICE.md) for third-party data and attributions.
>
> **Platform:** Android only. iOS is not supported.
>
> The UI is in Italian and the project docs in `docs/` are mostly in Italian.

## Features

- Food diary with local CREA database, Open Food Facts search and barcode scanning
- Meal-plan generator (macro targets, preferences, alternatives)
- TDEE / macro calculation, skinfold and circumference measurements, progress charts
- Workout plans, exercise catalog, progression, supersets and advanced techniques per exercise
- Smartwatch data via Health Connect
- AI Coach (Gemini): you paste your own API key in the app settings; requests go straight from your device to Google's Gemini API

## Build it locally

Requirements: Flutter **3.44.1** (stable, Dart 3.12.1), Android SDK, a device or emulator with Android 5.0+ (API 21+).

```bash
git clone <this repo>
cd plico_open
flutter pub get
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

Without a `key.properties` file the release build is signed with the debug key, which is fine for
installing on your own devices. To run on a connected device: `flutter run --release`.

To use the Coach, create an API key at https://aistudio.google.com and paste it in the app's settings.

### After changing data models

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Tests

```bash
flutter test
```

Desktop tests that open Isar need the native `libisar.so` available in the project root
(see the Isar documentation).

## Regenerating the bundled data

- `tool/seed_crea.dart`: `crea_food_composition_tables.csv` → `assets/data/crea_seed.json`
- `tool/seed_exercises.dart`: `exercise_db_raw.json` → `assets/data/exercises_seed.json`
- `scripts/normalize_foods.py`: normalizes food names

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Security reports: [SECURITY.md](SECURITY.md).
