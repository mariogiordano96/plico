import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'progressi/progressi_screen.dart';
import 'storico/storico_misurazioni_screen.dart';
import 'pesate/pesate_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          ProgressiScreen(),
          StoricoMisurazioniScreen(),
          PesateScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: p.surface,
          indicatorColor: p.accent.withValues(alpha: 0.15),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: p.accent);
            }
            return IconThemeData(color: p.textMuted);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(color: p.accent, fontSize: 11, fontWeight: FontWeight.w600);
            }
            return TextStyle(color: p.textMuted, fontSize: 11);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.show_chart_outlined),
              selectedIcon: Icon(Icons.show_chart_rounded),
              label: 'Progressi',
            ),
            NavigationDestination(
              icon: Icon(Icons.straighten_outlined),
              selectedIcon: Icon(Icons.straighten_rounded),
              label: 'Misurazioni',
            ),
            NavigationDestination(
              icon: Icon(Icons.monitor_weight_outlined),
              selectedIcon: Icon(Icons.monitor_weight_rounded),
              label: 'Pesate',
            ),
          ],
        ),
      ),
    );
  }
}
