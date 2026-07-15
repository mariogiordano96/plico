import 'package:flutter/material.dart';

/// Sostituisce l'intero stack di navigazione con [destinationBuilder].
///
/// Usato per uscire da flussi come l'onboarding: usa `pushAndRemoveUntil`
/// invece di `pushReplacement` così qualunque route ci sia sotto quella
/// corrente (es. la schermata di benvenuto, raggiunta con `Navigator.push`
/// e quindi ancora nello stack) viene rimossa, non solo l'ultima. Altrimenti
/// la schermata di destinazione mostra una freccia indietro spuria verso
/// una schermata del flusso che l'utente non dovrebbe poter più rivedere.
void replaceEntireStack(BuildContext context, WidgetBuilder destinationBuilder) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: destinationBuilder),
    (route) => false,
  );
}
