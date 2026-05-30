import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Neon palette
  static const neonCyan = Color(0xFF00E5FF);
  static const neonBlue = Color(0xFF2979FF);
  static const neonPurple = Color(0xFFB388FF);
  static const neonPink = Color(0xFFFF4081);
  static const neonGreen = Color(0xFF00E676);

  // Aliases for compatibility (used in older widgets)
  static Color get accent => neonCyan;
  static Color get accentDeep => neonBlue;
  static Color get accentSoft => neonPurple;

  // Dark base
  static const darkBgTop = Color(0xFF0F1228);
  static const darkBgBottom = Color(0xFF050617);
  static const darkSurface = Color(0xFF141738);
  static const darkSurfaceGlass = Color(0x33FFFFFF);
  static const darkText = Color(0xFFE8ECFF);
  static const darkTextMuted = Color(0xFF8089B5);
  static const darkDot = Color(0xFF1F2547);
  static const darkCardShadow = Color(0x66000000);
  static const darkGridLine = Color(0x1A00E5FF);

  // Light base (kept for backward compat but de-emphasized)
  static const lightBgTop = Color(0xFFE8F0FA);
  static const lightBgBottom = Color(0xFFC9D5E5);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF0F1228);
  static const lightTextMuted = Color(0xFF526A8C);
  static const lightDot = Color(0xFFA8B8D0);
  static const lightCardShadow = Color(0x22000000);
  static const lightGridLine = Color(0x222979FF);

  static const heart = Color(0xFFFF4081);
  static const heartDeep = Color(0xFFD81B60);
  static const star = Color(0xFFFFEB3B);
}

class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final isLight = b == Brightness.light;
    final surface = isLight ? AppColors.lightSurface : AppColors.darkSurface;
    final text = isLight ? AppColors.lightText : AppColors.darkText;
    final muted = isLight ? AppColors.lightTextMuted : AppColors.darkTextMuted;

    final baseTheme = ThemeData(
      brightness: b,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.neonCyan,
        brightness: b,
        surface: surface,
        primary: AppColors.neonCyan,
        secondary: AppColors.neonPurple,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.orbitron(
          color: text,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
          color: text,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
        headlineMedium: GoogleFonts.orbitron(
          color: text,
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
        ),
        titleLarge: GoogleFonts.orbitron(
          color: text,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
        bodyLarge: GoogleFonts.rajdhani(color: text, fontSize: 16),
        bodyMedium: GoogleFonts.rajdhani(color: muted, fontSize: 14),
        labelLarge: GoogleFonts.orbitron(
          color: text,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.neonCyan,
          foregroundColor: AppColors.darkBgBottom,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
          elevation: 8,
          shadowColor: AppColors.neonCyan,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: AppColors.neonCyan, width: 1.5),
          foregroundColor: AppColors.neonCyan,
          textStyle: GoogleFonts.orbitron(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.5,
          ),
        ),
      ),
    );

    return baseTheme;
  }
}
