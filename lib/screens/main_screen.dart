import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_tour.dart';
import 'home_screen.dart';
import 'diario/diario_screen.dart';
import 'progressi/progressi_screen.dart';
import 'tdee/tdee_screen.dart';

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
    return AppTour(
      onSwitchTab: _switchTab,
      child: Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onSwitchTab: _switchTab),
          const DiarioScreen(),
          const ProgressiScreen(),
          const TdeeScreen(),
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_rounded),
              label: 'Diario',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Progressi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_fire_department_rounded),
              label: 'TDEE',
            ),
          ],
        ),
      ),
      ),
    ));
  }
}
