import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'motion.dart';

const _fontFamily = 'Space Grotesk';

const _pageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: AppPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.linux: AppPageTransitionsBuilder(),
    TargetPlatform.windows: AppPageTransitionsBuilder(),
  },
);

// ──────────────────────────────────────────────
// ColorPalette — accesso ai colori tema-aware
// ──────────────────────────────────────────────
class ColorPalette {
  const ColorPalette({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.accent,
    required this.accentSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.cardBorder,
    required this.error,
  });

  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color accent;
  final Color accentSecondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color cardBorder;
  final Color error;
}

const _dark = ColorPalette(
  background:     Color(0xFF0B1622),
  surface:        Color(0xFF162035),
  surfaceVariant: Color(0xFF1A2840),
  accent:         Color(0xFF00FF88),
  accentSecondary:Color(0xFF7FFF00),
  textPrimary:    Color(0xFFE8F2FF),
  textSecondary:  Color(0xFF7DB8CC),
  textMuted:      Color(0xFF4A6B7A),
  cardBorder:     Color(0xFF1E3A50),
  error:          Color(0xFFFF4D6D),
);

const _light = ColorPalette(
  background:     Color(0xFFF2FAF5),
  surface:        Color(0xFFFFFFFF),
  surfaceVariant: Color(0xFFE8F5EE),
  accent:         Color(0xFF00995A),
  accentSecondary:Color(0xFF4A8800),
  textPrimary:    Color(0xFF0A1A0F),
  textSecondary:  Color(0xFF2D6A4A),
  textMuted:      Color(0xFF7A9A85),
  cardBorder:     Color(0xFFBEDDCA),
  error:          Color(0xFFD32F4F),
);

extension PaletteX on BuildContext {
  ColorPalette get palette =>
      Theme.of(this).brightness == Brightness.dark ? _dark : _light;
}

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

// ──────────────────────────────────────────────
// Colori per ThemeData (const, non tramite _dark/_light: il compilatore non
// accetta l'accesso a una proprietà di un'istanza const in un'espressione
// costante — vedi ColorPalette sopra, usata invece a runtime via `context.palette`).
// ──────────────────────────────────────────────
class AppColors {
  static const background = Color(0xFF0B1622);
  static const surface = Color(0xFF162035);
  static const surfaceVariant = Color(0xFF1A2840);
  static const accent = Color(0xFF00FF88);
  static const accentSecondary = Color(0xFF7FFF00);
  static const accentDim = Color(0xFF00CC6A);
  static const textPrimary = Color(0xFFE8F2FF);
  static const textSecondary = Color(0xFF7DB8CC);
  static const textMuted = Color(0xFF4A6B7A);
  static const cardBorder = Color(0xFF1E3A50);
  static const error = Color(0xFFFF4D6D);
}

class AppColorsLight {
  static const background = Color(0xFFF2FAF5);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFE8F5EE);
  static const accent = Color(0xFF00995A);
  static const accentSecondary = Color(0xFF4A8800);
  static const textPrimary = Color(0xFF0A1A0F);
  static const textSecondary = Color(0xFF2D6A4A);
  static const textMuted = Color(0xFF7A9A85);
  static const cardBorder = Color(0xFFBEDDCA);
  static const error = Color(0xFFD32F4F);
}

// ──────────────────────────────────────────────
// Dark theme
// ──────────────────────────────────────────────
final darkTheme = ThemeData(
  brightness: Brightness.dark,
  pageTransitionsTheme: _pageTransitionsTheme,
  scaffoldBackgroundColor: const Color(0xFF0B1622),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF00FF88),
    secondary: Color(0xFF7FFF00),
    surface: Color(0xFF162035),
    error: Color(0xFFFF4D6D),
    onPrimary: Color(0xFF0B1622),
    onSecondary: Color(0xFF0B1622),
    onSurface: Color(0xFFE8F2FF),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0B1622),
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: _fontFamily,
      color: AppColors.accent,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 2,
    ),
    iconTheme: IconThemeData(color: AppColors.accent),
  ),
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: AppColors.cardBorder, width: 1),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceVariant,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.cardBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.cardBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
    ),
    labelStyle: const TextStyle(color: AppColors.textSecondary),
    suffixStyle: const TextStyle(color: AppColors.textMuted),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.background,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
    displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
    headlineLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(color: AppColors.textSecondary),
    bodyLarge: TextStyle(color: AppColors.textPrimary),
    bodyMedium: TextStyle(color: AppColors.textSecondary),
    bodySmall: TextStyle(color: AppColors.textMuted),
  ).apply(fontFamily: _fontFamily),
);

// ──────────────────────────────────────────────
// Light theme
// ──────────────────────────────────────────────
final lightTheme = ThemeData(
  brightness: Brightness.light,
  pageTransitionsTheme: _pageTransitionsTheme,
  scaffoldBackgroundColor: AppColorsLight.background,
  colorScheme: const ColorScheme.light(
    primary: AppColorsLight.accent,
    secondary: AppColorsLight.accentSecondary,
    surface: AppColorsLight.surface,
    error: AppColorsLight.error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColorsLight.textPrimary,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColorsLight.background,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: _fontFamily,
      color: AppColorsLight.accent,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 2,
    ),
    iconTheme: IconThemeData(color: AppColorsLight.accent),
  ),
  cardTheme: CardThemeData(
    color: AppColorsLight.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: AppColorsLight.cardBorder, width: 1),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColorsLight.surfaceVariant,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColorsLight.cardBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColorsLight.cardBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColorsLight.accent, width: 1.5),
    ),
    labelStyle: const TextStyle(color: AppColorsLight.textSecondary),
    suffixStyle: const TextStyle(color: AppColorsLight.textMuted),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColorsLight.accent,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: AppColorsLight.textPrimary, fontWeight: FontWeight.w700),
    displayMedium: TextStyle(color: AppColorsLight.textPrimary, fontWeight: FontWeight.w700),
    headlineLarge: TextStyle(color: AppColorsLight.textPrimary, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(color: AppColorsLight.textPrimary, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(color: AppColorsLight.textPrimary, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(color: AppColorsLight.textPrimary, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(color: AppColorsLight.textSecondary),
    bodyLarge: TextStyle(color: AppColorsLight.textPrimary),
    bodyMedium: TextStyle(color: AppColorsLight.textSecondary),
    bodySmall: TextStyle(color: AppColorsLight.textMuted),
  ).apply(fontFamily: _fontFamily),
);

// Kept for backward compatibility
final appTheme = darkTheme;
