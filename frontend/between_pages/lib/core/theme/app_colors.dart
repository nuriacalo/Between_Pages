import 'package:flutter/material.dart';

class AppColors {
  // ── MODO CLARO ────────────────────────────────
  static const lightBackground    = Color(0xFFF5E6E0);
  static const lightSurface       = Color(0xFFFDF5F2);
  static const lightCard          = Color(0xFFFFFFFF);
  static const lightBorder        = Color(0xFFF1C5C1);
  static const lightTextPrimary   = Color(0xFF524D5F);
  static const lightTextSecondary = Color(0xFF8C8098);
  static const lightAccent        = Color(0xFFA87C80);
  static const lightIcons         = Color(0xFF7F8C95);
  static const lightEmphasis      = Color(0xFFE8A87C);

  // ── MODO OSCURO ───────────────────────────────
  static const darkBackground     = Color(0xFF2C2025);
  static const darkSurface        = Color(0xFF3D2D30);
  static const darkCard           = Color(0xFF4A3538);
  static const darkBorder         = Color(0xFF5C4448);
  static const darkTextPrimary    = Color(0xFFF5E6E0);
  static const darkTextSecondary  = Color(0xFFB89FA3);
  static const darkAccent         = Color(0xFFD4A0A4);
  static const darkIcons          = Color(0xFF9FB3BC);
  static const darkEmphasis       = Color(0xFFE8C49A);

  // ── ESTADOS (iguales en ambos modos) ─────────
  static const statusReading   = Color(0xFF7BAE8E);
  static const statusPending   = Color(0xFFE8C47A);
  static const statusFinished  = Color(0xFFA87C80);
  static const statusAbandoned = Color(0xFFB07070);

  // ── TIPO DE CONTENIDO ─────────────────────────
  static const colorLibro  = Color(0xFF7F8C95);
  static const colorFanfic = Color(0xFFD4A0A4);
  static const colorManga  = Color(0xFFE8A87C);

  // ── HELPERS DINÁMICOS ─────────────────────────
  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) => isDark(context) ? darkBackground : lightBackground;
  static Color surface(BuildContext context) => isDark(context) ? darkSurface : lightSurface;
  static Color card(BuildContext context) => isDark(context) ? darkCard : lightCard;
  static Color border(BuildContext context) => isDark(context) ? darkBorder : lightBorder;
  static Color textPrimary(BuildContext context) => isDark(context) ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(BuildContext context) => isDark(context) ? darkTextSecondary : lightTextSecondary;
  static Color accent(BuildContext context) => isDark(context) ? darkAccent : lightAccent;
  static Color icons(BuildContext context) => isDark(context) ? darkIcons : lightIcons;
  static Color emphasis(BuildContext context) => isDark(context) ? darkEmphasis : lightEmphasis;
}