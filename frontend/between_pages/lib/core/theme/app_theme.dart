import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary:          AppColors.lightAccent,
        secondary:        AppColors.lightEmphasis,
        surface:          AppColors.lightSurface,
        onPrimary:        Colors.white,
        onSurface:        AppColors.lightTextPrimary,
        outline:          AppColors.lightBorder,
      ),
      textTheme: _textTheme(AppColors.lightTextPrimary, AppColors.lightTextSecondary),
      cardTheme: _cardTheme(AppColors.lightCard, AppColors.lightBorder),
      appBarTheme: _appBarTheme(AppColors.lightBackground, AppColors.lightTextPrimary),
      inputDecorationTheme: _inputTheme(AppColors.lightSurface, AppColors.lightTextSecondary, AppColors.lightBorder),
      bottomNavigationBarTheme: _bottomNavTheme(AppColors.lightSurface, AppColors.lightAccent, AppColors.lightTextSecondary),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary:          AppColors.darkAccent,
        secondary:        AppColors.darkEmphasis,
        surface:          AppColors.darkSurface,
        onPrimary:        Colors.white,
        onSurface:        AppColors.darkTextPrimary,
        outline:          AppColors.darkBorder,
      ),
      textTheme: _textTheme(AppColors.darkTextPrimary, AppColors.darkTextSecondary),
      cardTheme: _cardTheme(AppColors.darkCard, AppColors.darkBorder),
      appBarTheme: _appBarTheme(AppColors.darkBackground, AppColors.darkTextPrimary),
      inputDecorationTheme: _inputTheme(AppColors.darkSurface, AppColors.darkTextSecondary, AppColors.darkBorder),
      bottomNavigationBarTheme: _bottomNavTheme(AppColors.darkSurface, AppColors.darkAccent, AppColors.darkTextSecondary),
    );
  }

  // ── Helpers privados ─────────────────────────

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge:  GoogleFonts.lora(fontSize: 28, fontWeight: FontWeight.bold,   color: primary),
      displayMedium: GoogleFonts.lora(fontSize: 24, fontWeight: FontWeight.bold,   color: primary),
      titleLarge:    GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.w600,   color: primary),
      titleMedium:   GoogleFonts.lora(fontSize: 17, fontWeight: FontWeight.w600,   color: primary),
      bodyLarge:     GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.normal, color: primary),
      bodyMedium:    GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.normal, color: primary),
      bodySmall:     GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.normal, color: secondary),
      labelLarge:    GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600,   color: primary),
      labelSmall:    GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w500,   color: secondary),
    );
  }

static CardThemeData _cardTheme(Color color, Color border) {
  return CardThemeData(
    color: color,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: border, width: 1),
    ),
  );
}

  static AppBarTheme _appBarTheme(Color bg, Color text) {
    return AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.lora(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: text,
      ),
      iconTheme: IconThemeData(color: text),
    );
  }

  static InputDecorationTheme _inputTheme(Color fill, Color hint, Color border) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      hintStyle: GoogleFonts.nunito(color: hint, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.lightAccent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  static BottomNavigationBarThemeData _bottomNavTheme(Color bg, Color selected, Color unselected) {
    return BottomNavigationBarThemeData(
      backgroundColor: bg,
      selectedItemColor: selected,
      unselectedItemColor: unselected,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    );
  }
}