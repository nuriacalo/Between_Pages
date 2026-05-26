import 'package:flutter/material.dart';

class AppColors {
  // ─────────────────────────────────────────────
  // LIGHT MODE
  // ─────────────────────────────────────────────

  /// Fondo principal cálido tipo papel
  static const lightBackground = Color(0xFFF5E6E0);

  /// Superficies secundarias
  static const lightSurface = Color(0xFFFDF5F2);

  /// Cards ligeramente crema (menos blanco puro)
  static const lightCard = Color(0xFFFFFAF8);

  /// Bordes suaves tipo papel envejecido
  static const lightBorder = Color(0xFFE9D7D2);

  /// Texto principal
  static const lightTextPrimary = Color(0xFF524D5F);

  /// Texto secundario
  static const lightTextSecondary = Color(0xFF8C8098);

  /// Color principal dusty rose
  static const lightAccent = Color(0xFFA87C80);

  /// Iconos / elementos neutros
  static const lightIcons = Color(0xFF7F8C95);

  /// Énfasis cálido
  static const lightEmphasis = Color(0xFFE8A87C);

  ///Color vibrante para acciones de logout o destructivas
  static const logoutColor = Color(0xFFC85C5C);

  // ─────────────────────────────────────────────
  // DARK MODE
  // ─────────────────────────────────────────────

  /// Fondo principal oscuro cálido
  static const darkBackground = Color(0xFF2C2025);

  /// Superficies secundarias
  static const darkSurface = Color(0xFF3D2D30);

  /// Cards con un poco más de contraste
  static const darkCard = Color(0xFF523D41);

  /// Bordes suaves oscuros
  static const darkBorder = Color(0xFF5C4448);

  /// Texto principal
  static const darkTextPrimary = Color(0xFFF5E6E0);

  /// Texto secundario
  static const darkTextSecondary = Color(0xFFB89FA3);

  /// Accent oscuro
  static const darkAccent = Color(0xFFD4A0A4);

  /// Iconos
  static const darkIcons = Color(0xFF9FB3BC);

  /// Énfasis cálido oscuro
  static const darkEmphasis = Color(0xFFE8C49A);

  /// Color profundo para acciones principales
  static const darkAnchor = Color(0xFFD4A0A4);

  ///Color vibrante para acciones de logout o destructivas
  static const logoutDarkColor = Color(0xFFD97B7B);

  // ─────────────────────────────────────────────
  // STATUS COLORS
  // ─────────────────────────────────────────────

  static const statusReading = Color(0xFF7BAE8E);
  static const statusPending = Color(0xFFE8C47A);
  static const statusFinished = Color(0xFFA87C80);
  static const statusAbandoned = Color(0xFFB07070);
  static const statusTBR = Color(0xFF9FB3BC); 

  // ─────────────────────────────────────────────
  // CONTENT TYPES
  // ─────────────────────────────────────────────

  static const colorLibro = Color(0xFF7F8C95);
  static const colorFanfic = Color(0xFFD4A0A4);
  static const colorManga = Color(0xFFE8A87C);

  // ─────────────────────────────────────────────
  // HELPERS DINÁMICOS
  // ─────────────────────────────────────────────

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      isDark(context) ? darkBackground : lightBackground;

  static Color surface(BuildContext context) =>
      isDark(context) ? darkSurface : lightSurface;

  static Color card(BuildContext context) =>
      isDark(context) ? darkCard : lightCard;

  static Color border(BuildContext context) =>
      isDark(context) ? darkBorder : lightBorder;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? darkTextPrimary : lightTextPrimary;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? darkTextSecondary : lightTextSecondary;

  static Color accent(BuildContext context) =>
      isDark(context) ? darkAccent : lightAccent;

  static Color icons(BuildContext context) =>
      isDark(context) ? darkIcons : lightIcons;

  static Color emphasis(BuildContext context) =>
      isDark(context) ? darkEmphasis : lightEmphasis;

  static Color logout(BuildContext context) =>
      isDark(context) ? logoutDarkColor : logoutColor;
}
