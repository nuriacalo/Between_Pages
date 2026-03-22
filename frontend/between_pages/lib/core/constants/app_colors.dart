// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // 1. Fondo Principal (El lienzo de la app)
  static const Color background = Color(0xFFF5E6E0); // Melocotón Suave

  // 2. Fondo Secundario (Tarjetas, menús, secciones elevadas)
  static const Color surface = Color(0xFFF1C5C1);    // Coral Pálido
  static const Color card = Color(0xFFF1C5C1);

  // 3. Texto Principal (Títulos y bloques de lectura)
  static const Color text = Color(0xFF524D5F);      // Gris Berenjena
  static const Color textSecondary = Color(0xFF7F8C95); // Azul Pizarra Suave

  // 4. Acento / Resaltado (Botones principales, progreso)
  static const Color primary = Color(0xFFA87C80);   // Rosa Antiguo

  // 5. Detalles / Íconos (Navegación, categorías)
  static const Color secondary = Color(0xFF7F8C95); // Azul Pizarra Suave
  static const Color icons = Color(0xFF7F8C95);

  // 6. Énfasis Suave (Estrellas, alertas, enlaces)
  static const Color accent = Color(0xFFE8A87C);    // Ámbar Cálido

  // Colores de estado (opcionales, manteniendo la estética)
  static const Color error = Color(0xFFD9534F);
  static const Color success = Color(0xFF829460);
}