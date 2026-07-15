import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plico/widgets/dismiss_keyboard_on_tap.dart';

void main() {
  testWidgets(
    'bug iOS: il tap fuori da un campo di testo chiude la tastiera'
    ' (nessun equivalente del tasto "chiudi tastiera" di Android)',
    (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: DismissKeyboardOnTap(
            child: Scaffold(
              body: Column(
                children: [
                  TextField(key: const Key('field'), focusNode: focusNode),
                  Container(key: const Key('outside'), height: 200, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('field')));
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      await tester.tap(find.byKey(const Key('outside')));
      await tester.pump();
      expect(focusNode.hasFocus, isFalse);
    },
  );

  testWidgets('il tap diretto su un campo di testo continua a dargli il focus', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: DismissKeyboardOnTap(
          child: Scaffold(body: TextField(key: const Key('field'), focusNode: focusNode)),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('field')));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);
  });
}
