import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_tour.dart';
import 'home_screen.dart';
import 'diario/diario_screen.dart';
import 'allenamento/allenamento_screen.dart';
import 'progressi/progressi_screen.dart';
import 'coach/coach_screen.dart';

/// Etichette della bottom navigation bar, nell'ordine delle tab.
@visibleForTesting
List<String> mainTabLabels(AppLocalizations l10n) => [
      l10n.tabHome,
      l10n.tabDiario,
      l10n.tabAllenamento,
      l10n.tabProgressi,
      l10n.tabCoach,
    ];

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  void _switchTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final labels = mainTabLabels(context.l10n);
    return AppTour(
      onSwitchTab: _switchTab,
      child: Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onSwitchTab: _switchTab),
          const DiarioScreen(),
          const AllenamentoScreen(),
          const ProgressiScreen(),
          const CoachScreen(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.cardBorder, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: _switchTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: p.surface,
          selectedItemColor: p.accent,
          unselectedItemColor: p.textMuted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: labels[0],
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_rounded),
              label: labels[1],
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_rounded),
              label: labels[2],
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: labels[3],
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_rounded),
              label: labels[4],
            ),
          ],
        ),
      ),
      ),
    ));
  }
}
