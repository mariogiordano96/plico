import 'package:flutter/widgets.dart';

/// Sceglie la lingua da usare tra le [supportedLocales], data la lista di
/// lingue preferite di sistema [systemLocales] (in ordine di preferenza).
///
/// Replica la logica di fallback di Flutter: la prima lingua di sistema
/// che compare tra quelle supportate, altrimenti la prima di
/// [supportedLocales]. Pensata per essere chiamata una sola volta al cold
/// start e il risultato fissato in un notifier non-null, così l'app non
/// segue più i cambi di lingua di sistema durante la sessione (su iOS,
/// cambiare la lingua della tastiera aggiorna anche le preferred languages
/// di sistema, facendo cambiare lingua all'app anche senza che l'utente
/// tocchi le Impostazioni).
Locale resolveInitialLocale(List<Locale> systemLocales, List<Locale> supportedLocales) {
  final supportedCodes = supportedLocales.map((l) => l.languageCode).toSet();
  for (final locale in systemLocales) {
    if (supportedCodes.contains(locale.languageCode)) return Locale(locale.languageCode);
  }
  return supportedLocales.first;
}
