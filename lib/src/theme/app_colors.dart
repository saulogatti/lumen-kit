import 'package:material_ui/material_ui.dart';

/// Application color palette (futuristic theme).
///
/// Centralizes visual tokens for reuse and easy maintenance.
class AppColors {
  const AppColors._();

  /// Deeper tone of the application background.
  static const Color backgroundDeep = Color(0xFF05060F);

  /// Intermediate tone used in background gradients.
  static const Color backgroundMid = Color(0xFF0B1023);

  /// Lighter tone of the background, used to soften the gradient.
  static const Color backgroundSoft = Color(0xFF11183A);

  /// Base color for cards, overlays and raised surfaces.
  static const Color surface = Color(0xFF131A38);

  /// Translucent outline used on surface edges.
  static const Color surfaceOutline = Color(0x3360E0FF);

  /// Subtle highlighting applied within translucent surfaces.
  static const Color surfaceHighlight = Color(0x1A60E0FF);

  /// Primary accent used on borders, icons, and active states.
  static const Color accentCyan = Color(0xFF00E5FF);

  /// Secondary accent used in glows and gradient compositions.
  static const Color accentMagenta = Color(0xFFB14BFF);

  /// Intermediate accent that connects cyan and magenta in gradients.
  static const Color accentBlue = Color(0xFF4D7CFE);

  /// Higher contrast color for titles and main content.
  static const Color textPrimary = Color(0xFFEAF6FF);

  /// Medium contrast color for supporting texts.
  static const Color textSecondary = Color(0xB3EAF6FF);

  /// Lower contrast color for subtitles, hints and auxiliary content.
  static const Color textMuted = Color(0x80EAF6FF);

  /// Semantic color for success states.
  static const Color success = Color(0xFF22E0A1);

  /// Semantic color for alert states.
  static const Color warning = Color(0xFFFFC857);

  /// Semantic color for error or danger states.
  static const Color danger = Color(0xFFFF5C7A);

  /// Gradient application background pattern.
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundDeep, backgroundMid, backgroundSoft],
    stops: [0.0, 0.55, 1.0],
  );

  /// Highlight gradient used in CTAs, indicators and active elements.
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentCyan, accentBlue, accentMagenta],
  );
}
