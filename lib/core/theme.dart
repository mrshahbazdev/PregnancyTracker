import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warm, calm, reassuring visual language for the app.
class AppColors {
  static const Color primary = Color(0xFFE5739B); // soft rose
  static const Color primaryDark = Color(0xFFC2547C);
  static const Color secondary = Color(0xFF7C9CCB); // calm blue
  static const Color accent = Color(0xFFF4A9A8); // peach
  static const Color background = Color(0xFFFCF7F8);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF3A2E33);
  static const Color textMuted = Color(0xFF8C7E84);

  // Dark mode colors
  static const Color backgroundDark = Color(0xFF1A1218);
  static const Color surfaceDark = Color(0xFF261E22);
  static const Color textLightDark = Color(0xFFF5EDF0);
  static const Color textMutedDark = Color(0xFF9E8F95);
}

/// Theme mode options persisted to local storage.
enum AppThemeMode { system, light, dark }

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.nunito(
              fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
    );

    return base.copyWith(
      textTheme: GoogleFonts.nunitoTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: AppColors.textLightDark,
        displayColor: AppColors.textLightDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textLightDark,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.nunito(
              fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

/// Helper to get the correct text/muted color based on current brightness.
extension ThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get textColor =>
      isDark ? AppColors.textLightDark : AppColors.textDark;
  Color get mutedColor =>
      isDark ? AppColors.textMutedDark : AppColors.textMuted;
  Color get surfaceColor =>
      isDark ? AppColors.surfaceDark : AppColors.surface;
  Color get backgroundColor =>
      isDark ? AppColors.backgroundDark : AppColors.background;
}
