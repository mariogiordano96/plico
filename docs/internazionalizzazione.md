# Internazionalizzazione — Plico

> Obiettivo: portare Plico su mercati anglofoni, ispanici e lusofoni senza sacrificare
> l'esperienza italiana esistente. La lingua è la principale barriera all'adozione
> per un'app di nicchia come un tracker nutrizionale.

---

## Stato attuale

| Aspetto | Stato |
|---|---|
| `flutter_localizations` in pubspec.yaml | ✅ già presente |
| Delegate `GlobalMaterialLocalizations` in main.dart | ✅ già presente |
| File `.arb` con stringhe dell'app | ❌ assenti |
| Pacchetto `intl` | ❌ assente |
| `AppLocalizations` generato | ❌ assente |
| Stringhe hardcodate in italiano | ~200+ in 63 file Dart |
| Date formattate con `padLeft()` manuale | ❌ non locale-aware |
| Numeri formattati con `toStringAsFixed()` | ❌ non locale-aware |

La struttura di base è pronta: mancano il layer di traduzione e l'estrazione delle stringhe.

---

## Lingue target

| Lingua | Priorità | Motivazione |
|---|---|---|
| Inglese (en) | 1 — obbligatoria | App Store / Play Store globale; lingua franca tech |
| Spagnolo (es) | 2 — alta | 500M+ parlanti nativi; mercato LATAM enorme |
| Portoghese (pt) | 3 — media | Brasile (220M), Portogallo; facile da coprire dopo es |
| Francese (fr) | 4 — bassa | Europa occidentale + Africa francofona |
| Tedesco (de) | 5 — bassa | Mercato DACH; alta capacità di spesa |

**Per v1 internazionale: IT + EN.** Le altre lingue si aggiungono dopo con un solo file ARB ciascuna.

---

## Setup tecnico

### 1. Dipendenze (`pubspec.yaml`)

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0          # già necessario per DateFormat/NumberFormat

flutter:
  generate: true          # abilita codegen AppLocalizations
```

### 2. Configurazione (`l10n.yaml` in root)

```yaml
arb-dir: lib/l10n
template-arb-file: app_it.arb
output-localization-file: app_localizations.dart
```

### 3. Struttura file

```
lib/
  l10n/
    app_it.arb    ← baseline italiano (template)
    app_en.arb    ← inglese
    app_es.arb    ← spagnolo (v2)
    app_pt.arb    ← portoghese (v2)
```

### 4. `main.dart`

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

MaterialApp(
  localizationsDelegates: [
    AppLocalizations.delegate,         // ← aggiungere
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
);
```

### 5. Utilizzo in widget

```dart
// Shortcut via extension (da aggiungere)
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

// Uso
Text(context.l10n.homeCalorieDiOggi)
```

---

## Il problema del database alimenti

Questa è la sfida principale dell'internazionalizzazione.

### Fonte attuale: CREA (Banca Dati italiana)

Il DB alimenti (`FoodItem`) contiene ~80 voci CREA + 6 custom, con nomi in italiano
hardcoded nel seed (`assets/data/crea_seed.json`). Es: `"Petto di pollo"`, `"Riso bianco"`.

Il campo `MealEntry.foodNome` in `DailyLog` è un **snapshot del nome al momento del log**:
è denormalizzato e non fa riferimento al `FoodItem` per id. Questo crea un problema:
se l'utente cambia lingua, le voci storiche del diario restano in italiano.

### Strategia consigliata per i FoodItem seedati

**Aggiungere traduzioni direttamente nel seed JSON:**

```json
{
  "id": "CREA001",
  "nome": "Petto di pollo",
  "nomeEn": "Chicken breast",
  "nomeEs": "Pechuga de pollo",
  "nomePt": "Peito de frango",
  "kcalPer100g": 110.0,
  ...
}
```

**Aggiungere campi al modello `FoodItem`:**

```dart
@collection
class FoodItem {
  // ... campi esistenti ...
  String? nomeEn;
  String? nomeEs;
  String? nomePt;
  String? nomeFr;

  String localizedName(String languageCode) {
    return switch (languageCode) {
      'en' => nomeEn ?? nome,
      'es' => nomeEs ?? nome,
      'pt' => nomePt ?? nome,
      'fr' => nomeFr ?? nome,
      _ => nome,
    };
  }
}
```

Per ~80 alimenti, la traduzione è fattibile manualmente in un pomeriggio (i nomi sono
tutti alimenti comuni: pollo, riso, uova, ecc.).

### Problema MealEntry.foodNome (diario storico)

`MealEntry` salva il nome come stringa snapshot senza riferimento all'id del `FoodItem`.
Le voci storiche del diario restano nella lingua in cui sono state inserite.

**Soluzione pragmatica per v1:** accettare il comportamento. Il diario è personale e
cronologico — non è strano che una voce del passato resti nel nome originale. L'importante
è che i nuovi inserimenti usino il nome localizzato.

**Soluzione completa (futura):** aggiungere `foodItemId: int?` a `MealEntry`. Se presente,
al display si richiede il nome localizzato dal `FoodItem`; se assente (voci vecchie o
da barcode senza corrispondenza nel DB) si usa `foodNome` come fallback.

### Open Food Facts (ricerca/barcode)

Open Food Facts supporta già nomi multilingua nella risposta API:
`product_name`, `product_name_en`, `product_name_it`, `product_name_fr`, ecc.

Al momento l'app usa solo `product_name` (lingua del packaging). La modifica è semplice:

```dart
// In barcode/search service, scegliere il campo in base alla locale
final name = product['product_name_${locale.languageCode}']
          ?? product['product_name_en']
          ?? product['product_name']
          ?? '';
```

### Alimenti custom dell'utente

Gli alimenti custom (inseriti manualmente dall'utente) restano nel nome che l'utente ha
scritto — nessuna traduzione richiesta, è contenuto utente.

---

## Cosa va tradotto (oltre agli alimenti)

### UI strings (~200 stringhe)

Tutte le label, placeholder, messaggi di errore, titoli, descrizioni. Distribuite in:
- 19 file schermate
- Widget condivisi (app_tour.dart, home_screen, ecc.)
- Notifiche locali (titoli e body)
- PDF export (intestazioni del piano)

### Notifiche push

I testi delle notifiche locali sono hardcoded in `notifiche_screen.dart` e nel service
delle notifiche. Devono usare la lingua del device al momento in cui la notifica viene
schedulata (non al momento in cui viene mostrata — Flutter non può cambiare retroattivamente
il testo di una notifica schedulata).

### PDF export

Le intestazioni del PDF (`"Piano Alimentare"`, `"Colazione"`, `"Pranzo"`, ecc.)
devono usare la lingua corrente al momento dell'export.

### Enumerazioni visualizzate

`PastoTipo` (colazione, pranzo, cena, ecc.) e i livelli di attività sono già interi in DB
ma vengono visualizzati come stringhe in molti punti. Centralizzare il mapping in
un'extension locale-aware:

```dart
extension PastoTipoLabel on int {
  String label(BuildContext context) {
    return switch (this) {
      0 => context.l10n.pastoColazione,
      1 => context.l10n.pastoPranzo,
      2 => context.l10n.pastoCena,
      3 => context.l10n.pastoSpuntino,
      _ => '',
    };
  }
}
```

### Date e numeri

```dart
// Attuale (non locale-aware)
'${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}'

// Corretto
DateFormat.yMd(locale.languageCode).format(d)
// → "19/06/2026" in IT, "6/19/2026" in EN

// Numeri decimali
NumberFormat('#,##0.0', locale.languageCode).format(peso)
// → "72,5" in IT, "72.5" in EN
```

---

## Piano di implementazione

### Fase 1 — Setup infrastruttura (0.5 gg)
- [ ] Aggiungere `intl` a `pubspec.yaml`
- [ ] Aggiungere `generate: true` sotto `flutter:`
- [ ] Creare `l10n.yaml` in root
- [ ] Creare `lib/l10n/app_it.arb` vuoto
- [ ] Aggiungere `AppLocalizations.delegate` in `main.dart`
- [ ] Aggiungere extension `context.l10n`

### Fase 2 — Estrazione stringhe IT (2–3 gg)
- [ ] Estrarre tutte le stringhe dalle 19 schermate in `app_it.arb`
- [ ] Sostituire le stringhe hardcodate con `context.l10n.chiave`
- [ ] Centralizzare i label di `PastoTipo`, livelli attività, obiettivi
- [ ] Aggiornare notifiche locali per usare stringhe localizzate

### Fase 3 — Traduzione EN (1 gg)
- [ ] Creare `app_en.arb` con tutte le ~200 chiavi tradotte in inglese
- [ ] Tradurre `crea_seed.json` aggiungendo campo `nomeEn` per ~80 alimenti
- [ ] Aggiornare barcode service per usare `product_name_en` se locale = en

### Fase 4 — Date, numeri, PDF (0.5 gg)
- [ ] Sostituire tutti i `padLeft` con `DateFormat`
- [ ] Sostituire `toStringAsFixed` con `NumberFormat` dove il numero è mostrato all'utente
- [ ] Aggiornare PDF export per usare stringhe localizzate

### Fase 5 — Test e rifinitura (1 gg)
- [ ] Testare su device con lingua impostata su EN
- [ ] Verificare che il piano alimentare e il PDF escano in inglese
- [ ] Verificare le notifiche locali
- [ ] Aggiornare `AppSettings` con un campo `languageCode` se si vuole override manuale
  (opzionale — di default si segue la lingua del sistema operativo)

**Stima totale: ~5–6 giorni di sviluppo**

---

## Considerazioni aperte

- **Override lingua in-app** — seguire la lingua del SO è il default e il più semplice.
  Se si vuole permettere all'utente di scegliere una lingua diversa dal SO, serve
  salvare `languageCode` in `AppSettings` e passarlo a `MaterialApp.locale`.

- **App Store / Play Store metadata** — i testi dello store (titolo, descrizione, screenshot)
  vanno localizzati separatamente tramite gli strumenti di Xcode / Google Play Console.
  Non è tecnicamente complesso ma richiede copywriting in ogni lingua.

- **Nomi alimenti nel diario storico** — come descritto sopra, le voci storiche resteranno
  nella lingua originale. Comunicarlo nelle note di release se necessario.

- **RTL (arabo, ebraico)** — fuori scope. Flutter supporta RTL nativamente ma richiederebbe
  revisione del layout di tutte le schermate.
