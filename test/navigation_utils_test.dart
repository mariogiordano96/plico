import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plico/utils/navigation_utils.dart';

/// Simula lo stack reale: WelcomeScreen -> Navigator.push -> OnboardingScreen
/// -> replaceEntireStack -> MainScreen. Il bug era che a fine onboarding si
/// usava `pushReplacement`, che sostituisce solo la route in cima e lascia
/// la schermata di benvenuto sotto quella finale, facendo comparire una
/// freccia indietro spuria nell'AppBar della Home.
void main() {
  testWidgets(
    'bug: dopo replaceEntireStack, la schermata di destinazione non può'
    ' tornare indietro anche se raggiunta con più route intermedie',
    (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                key: const Key('welcome-to-onboarding'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const _FakeOnboardingScreen()),
                ),
                child: const Text('Nuovo profilo'),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.byKey(const Key('welcome-to-onboarding')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('complete-onboarding')), findsOneWidget);

      await tester.tap(find.byKey(const Key('complete-onboarding')));
      await tester.pumpAndSettle();

      final mainScreenContext = tester.element(find.byKey(const Key('main-screen')));
      expect(Navigator.of(mainScreenContext).canPop(), isFalse);
    },
  );
}

class _FakeOnboardingScreen extends StatelessWidget {
  const _FakeOnboardingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          key: const Key('complete-onboarding'),
          onPressed: () => replaceEntireStack(
            context,
            (_) => const Scaffold(key: Key('main-screen'), body: Text('Main')),
          ),
          child: const Text('Completa'),
        ),
      ),
    );
  }
}
