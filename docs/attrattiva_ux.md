# Attrattiva UI/UX — Analisi e Piano di Miglioramento

> Obiettivo: alzare la percezione visiva e la cura delle micro-interazioni di Plico, senza
> toccare la logica di business. L'app è funzionalmente completa e distintiva (fusione
> allenamento+nutrizione, tecniche granulari, coach AI con guardrail — vedi `esercizi.md`,
> `evolutiva_esercizi.md`, `integrazione_flutter_gemma.md`), ma l'investimento su
> micro-interazioni e identità visiva è finora minimo rispetto al resto del prodotto.

---

## 1. Stato attuale

Fondamenta presenti:

- `lib/theme/app_theme.dart` — palette centralizzata, dark/light reali, accento
  verde/lime (`#00FF88`/`#7FFF00`) non generico, tema tech-oriented coerente col
  posizionamento del coach AI
- Onboarding a 6 step (`onboarding_screen.dart`) + tour guidato (`app_tour.dart`)
- Empty state gestiti in 4 schermate (`storico_misurazioni_screen.dart`,
  `piano_tab.dart`, `pesate_screen.dart`, `allenamento_screen.dart`) — ma implementati
  ad-hoc per schermata, nessun widget condiviso
- Grafici via `fl_chart` per peso/kcal in Progressi

Rifinitura assente o minima:

- **Nessun font custom**: `pubspec.yaml` non dichiara `fonts:`, l'app usa il font di
  sistema di default. È la differenza più economica-vs-impatto: cambia la percezione
  "prodotto" vs "prototipo" con una riga di configurazione
- **Animazioni marginali**: solo 7 file su 124 usano `AnimationController` o widget
  animati (`AnimatedContainer`/`AnimatedSwitcher`/`Hero`), e sono implementazioni
  puntuali, non un linguaggio di movimento condiviso (durate/curve non centralizzate)
- **Feedback aptico quasi assente**: `HapticFeedback` usato in un solo file
  (`rest_timer_sheet.dart`) — nessun feedback su azioni chiave (fine serie, salvataggio
  pasto, unlock achievement)
- **26 schermate** usano `CircularProgressIndicator` di default per i caricamenti,
  nessuno skeleton/shimmer
- **Nessuna celebrazione visiva** per streak/achievement/obiettivo raggiunto (il
  meccanismo di gamification esiste lato dati, ma non ha un momento "wow" a schermo)
- **Nessun asset di store** (screenshot, app preview) versionato nel repo

In sintesi: l'app è solida e coerente, ma "onesta" — comunica funzionalità senza
comunicare cura. È la differenza tra un'app che funziona bene e una che si vuole
mostrare.

---

## 2. Aree di intervento

### 2.1 Identità tipografica — priorità alta, sforzo bassissimo — ✅ Fatto

Sostituito il font di sistema con **Space Grotesk** (geometrico, coerente col tema
tech/accento lime), applicato via `ThemeData.textTheme` in `app_theme.dart` (4 pesi:
400/500/600/700).

Decisione presa in corso d'opera: **non** tramite il pacchetto `google_fonts` come
inizialmente valutato in questo documento, ma con i 4 file `.ttf` scaricati una tantum
e bundlati come asset locali in `assets/fonts/space_grotesk/`, dichiarati in
`pubspec.yaml` (`flutter: fonts:`). Motivo: `google_fonts` scarica di default il font
dal CDN Google al primo avvio (poi lo cachea) — un'eccezione all'impostazione
privacy-first già presente nell'app (nessun cloud sync, backup solo locale via
Wi-Fi/QR, vedi `backup_migrazione_dati.md`) ed espone l'IP dell'utente a un servizio
terzo senza consenso, un profilo di rischio GDPR concreto per un'app europea. Il bundle
locale ottiene lo stesso risultato visivo senza chiamate di rete e senza dipendenza
aggiuntiva in `pubspec.yaml`.

### 2.2 Linguaggio di movimento coerente — priorità alta

Oggi le animazioni sono isolate e non condivise. Serve un set minimo di primitive
riusabili in `lib/theme/` o `lib/widgets/motion/`:

- Durate/curve standard (es. `Durations.fast = 150ms`, `Durations.medium = 300ms`,
  `Curves.easeOutCubic` per entrate, `Curves.easeIn` per uscite)
- Transizioni di pagina custom (oggi presumibilmente quelle di default di
  `MaterialPageRoute`) — uno slide/fade leggero coerente col tema
- Entrata a cascata per liste (card esercizi, alimenti, storico) — effetto già comune
  nelle app fitness di riferimento (Hevy, Strong) e assente qui
- Feedback di pressione sui bottoni principali (scale leggero su tap)

Non serve un pacchetto esterno per questo: `AnimatedContainer`/`AnimatedSwitcher`/
`TweenAnimationBuilder` bastano se centralizzati in helper riusabili. Un pacchetto
come `flutter_animate` (non in `pubspec.yaml` oggi) velocizzerebbe l'adozione se si
preferisce non scrivere le primitive a mano.

### 2.3 Feedback aptico sistematico — priorità media, sforzo bassissimo

Estendere il pattern già presente in `rest_timer_sheet.dart` (`HapticFeedback`) ai
momenti chiave: fine serie in `sessione_guidata_screen.dart`, salvataggio pasto nel
diario, unlock achievement/streak, swipe-to-delete. Costo quasi nullo, impatto
percepito alto su dispositivo reale (l'audit da codice non lo cattura, va provato su
device).

### 2.4 Stati di caricamento — priorità media

Sostituire `CircularProgressIndicator` con skeleton screen nelle liste principali
(catalogo esercizi, catalogo alimenti, storico) — riduce la sensazione di attesa e fa
percepire l'app come più reattiva. Pacchetto `shimmer` (leggero, non in `pubspec.yaml`
oggi) o skeleton custom con `AnimatedContainer` + gradiente.

### 2.5 Momenti di celebrazione — priorità media

La gamification (streak, achievement, obiettivo calorico raggiunto — vedi
`miglioramenti.md`, voce "Feedback raggiungimento obiettivo") esiste lato dati ma non
ha un momento visivo dedicato. Un'animazione leggera (badge che si anima all'unlock,
non necessariamente confetti a schermo intero — rischia di essere invasivo su un'app
usata più volte al giorno) rinforza la retention, coerente con la nota già presente in
`miglioramenti.md` sull'abbandono come rischio principale.

### 2.6 Empty state condivisi — priorità bassa

Consolidare i 4 empty state ad-hoc in un widget comune (`EmptyStateView` con
icona/illustrazione, titolo, sottotitolo, CTA opzionale) per coerenza visiva e per
poterli aggiungere facilmente alle schermate che oggi non li hanno.

### 2.7 Asset di store — priorità bassa, ma bloccante per il lancio

Screenshot e (per iOS) app preview non sono versionati. Da produrre quando l'identità
visiva (2.1-2.2) è stabile, non prima — altrimenti vanno rifatti.

---

## 3. Pacchetti valutati

| Pacchetto | Uso | Note |
|---|---|---|
| ~~`google_fonts`~~ | Font custom | Valutato e **scartato** (vedi 2.1): scarica dal CDN Google al primo avvio, in contrasto con l'impostazione privacy-first dell'app. Sostituito da font bundlato localmente, zero dipendenze aggiuntive |
| `flutter_animate` | Animazioni dichiarative | Opzionale — accelera 2.2, ma le primitive si possono scrivere a mano senza dipendenza aggiuntiva |
| `shimmer` | Skeleton loading | Leggero, ma anche qui uno skeleton custom con `AnimatedContainer` evita la dipendenza |
| `confetti` | Celebrazione achievement | Solo se si sceglie l'opzione "confetti" in 2.5; da usare con parsimonia |

Nessuna è indispensabile: l'app può ottenere gran parte del miglioramento con asset
locali (font, come in 2.1) e primitive scritte a mano, mantenendo il footprint di
dipendenze minimo come è oggi — e senza introdurre chiamate di rete non necessarie,
coerente con l'impostazione privacy-first del progetto.

---

## 4. Piano a fasi

- [x] **Fase 1 — Identità tipografica**: font Space Grotesk bundlato localmente in
      `assets/fonts/space_grotesk/`, dichiarato in `pubspec.yaml`, applicato in
      `TextTheme` + `appBarTheme` + `elevatedButtonTheme` in `app_theme.dart` — nessuna
      modifica per-widget, effetto su tutte le schermate via tema
- [ ] **Fase 2 — Primitive di movimento**: creare `lib/theme/motion.dart` con
      durate/curve standard; transizioni di pagina custom; entrata a cascata per le
      liste principali (esercizi, alimenti, storico)
- [ ] **Fase 3 — Feedback aptico**: estendere `HapticFeedback` ai momenti chiave
      (fine serie, salvataggio pasto, unlock achievement, swipe-to-delete)
- [ ] **Fase 4 — Stati di caricamento**: skeleton screen per le liste principali,
      sostituendo `CircularProgressIndicator` dov'è più visibile (catalogo esercizi,
      catalogo alimenti)
- [ ] **Fase 5 — Momenti di celebrazione**: animazione unlock achievement/streak,
      feedback visivo obiettivo calorico raggiunto (collegato alla voce già pianificata
      in `miglioramenti.md`)
- [ ] **Fase 6 — Empty state condivisi**: `EmptyStateView` comune, applicato alle 4
      schermate esistenti + alle schermate che oggi non hanno empty state
- [ ] **Fase 7 — Asset di store**: screenshot e app preview, dopo che 1-2 sono stabili

Ogni fase è indipendente e non tocca la logica di business — solo `lib/theme/`,
`lib/widgets/` e presentazione nelle singole schermate. Commit + push a fine di ogni
fase completata, come da convenzione già in uso per i piani a fasi di questo progetto.
