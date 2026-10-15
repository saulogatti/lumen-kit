import 'package:material_ui/material_ui.dart';

/// Application color palette (futuristic theme).
/// Centralizes visual tokens for reuse and easy maintenance.
class AppColors {
  const AppColors._();

  /// Deepest tone of the application background.
  static const Color backgroundDeep = Color(0xFF05060F);

  /// Mid-tone used in background gradients.
  static const Color backgroundMid = Color(0xFF0B1023);

  /// Lightest background tone, used to soften the gradient.
  static const Color backgroundSoft = Color(0xFF11183A);

  /// Base color for cards, overlays, and elevated surfaces.
  static const Color surface = Color(0xFF131A38);

  /// Translucent outline used for surface borders.
  static const Color surfaceOutline = Color(0x3360E0FF);

  /// Subtle highlight applied inside translucent surfaces.
  static const Color surfaceHighlight = Color(0x1A60E0FF);

  /// Primary accent used for borders, icons, and active states.
  static const Color accentCyan = Color(0xFF00E5FF);

  /// Secondary accent used for glows and gradient compositions.
  static const Color accentMagenta = Color(0xFFB14BFF);

  /// Intermediate accent that connects cyan and magenta in gradients.
  static const Color accentBlue = Color(0xFF4D7CFE);

  /// Highest-contrast color for titles and main content.
  static const Color textPrimary = Color(0xFFEAF6FF);

  /// Medium-contrast color for supporting text.
  static const Color textSecondary = Color(0xB3EAF6FF);

  /// Lowest-contrast color for captions, hints, and auxiliary content.
  static const Color textMuted = Color(0x80EAF6FF);

  /// Semantic color for success states.
  static const Color success = Color(0xFF22E0A1);

  /// Semantic color for warning states.
  static const Color warning = Color(0xFFFFC857);

  /// Semantic color for error or danger states.
  static const Color danger = Color(0xFFFF5C7A);

  /// Default application background gradient.
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundDeep, backgroundMid, backgroundSoft],
    stops: [0.0, 0.55, 1.0],
  );

  /// Accent gradient used in CTAs, indicators, and active elements.
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentCyan, accentBlue, accentMagenta],
  );
}
