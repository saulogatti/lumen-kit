import 'package:flutter/material.dart';

/// Paleta de cores da aplicação (tema futurístico).
/// Centraliza tokens visuais para reuso e fácil manutenção.
class AppColors {
  const AppColors._();

  // Backgrounds
  static const Color backgroundDeep = Color(0xFF05060F);
  static const Color backgroundMid = Color(0xFF0B1023);
  static const Color backgroundSoft = Color(0xFF11183A);

  // Surfaces (cards / overlays)
  static const Color surface = Color(0xFF131A38);
  static const Color surfaceOutline = Color(0x3360E0FF);
  static const Color surfaceHighlight = Color(0x1A60E0FF);

  // Accents
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentMagenta = Color(0xFFB14BFF);
  static const Color accentBlue = Color(0xFF4D7CFE);

  // Text
  static const Color textPrimary = Color(0xFFEAF6FF);
  static const Color textSecondary = Color(0xB3EAF6FF);
  static const Color textMuted = Color(0x80EAF6FF);

  // Status
  static const Color success = Color(0xFF22E0A1);
  static const Color warning = Color(0xFFFFC857);
  static const Color danger = Color(0xFFFF5C7A);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundDeep, backgroundMid, backgroundSoft],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentCyan, accentBlue, accentMagenta],
  );
}
