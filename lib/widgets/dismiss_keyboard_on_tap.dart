import 'package:flutter/material.dart';

/// Chiude la tastiera al tocco fuori da un campo di testo.
///
/// Su Android il tasto indietro di sistema chiude comunque la tastiera; su
/// iOS non c'è un equivalente se il campo di testo non espone un pulsante
/// "fine" dedicato, quindi senza questo wrapper la tastiera può restare
/// aperta senza modo di chiuderla. Non interferisce con il tap diretto su
/// un campo di testo, che continua a dargli il focus normalmente.
class DismissKeyboardOnTap extends StatelessWidget {
  final Widget? child;
  const DismissKeyboardOnTap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
