import 'package:lumen_kit/src/theme/lumen_contrast.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Builds Material themes that include the Lumen palette and style.
///
/// Register a [LumenThemeExt] on an existing [ThemeData] to keep the app's own
/// typography and Material settings.
class AppTheme {
  // Private constructor that only blocks instantiation; nothing calls it.
  const AppTheme._(); // coverage:ignore-line

  /// Default dark theme using the default palette.
  static ThemeData get dark => fromPalette(LumenPalette.defaultDark());

  /// Light theme using the default light palette.
  static ThemeData get light => fromPalette(LumenPalette.light(), brightness: Brightness.light);

  /// Builds a theme from [primary] and optional [secondary] and [tertiary] colors.
  ///
  /// Uses [LumenPalette.fromSeed] with [brightness] and the optional
  /// [success], [warning], and [danger] colors, then passes the resulting
  /// palette, [brightness], and [style] to [fromPalette].
  static ThemeData fromSeed({
    required Color primary,
    Color? secondary,
    Color? tertiary,
    Brightness brightness = Brightness.dark,
    LumenStyle style = LumenStyle.neon,
    Color? success,
    Color? warning,
    Color? danger,
  }) => fromPalette(
    LumenPalette.fromSeed(
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      brightness: brightness,
      success: success,
      warning: warning,
      danger: danger,
    ),
    brightness: brightness,
    style: style,
  );

  /// Shortcut to use a [LumenPreset].
  static ThemeData fromPreset(
    LumenPreset preset, {
    Brightness brightness = Brightness.dark,
    LumenStyle style = LumenStyle.neon,
  }) => fromPalette(
    preset.palette(brightness: brightness),
    brightness: brightness,
    style: style,
  );

  /// Builds a Material 3 theme from the [p] palette.
  ///
  /// Sets the color scheme, scaffold background, text styles, app bar,
  /// icon colors, and divider color. Registers [p] and [style] in a
  /// [LumenThemeExt] for the kit's widgets.
  static ThemeData fromPalette(
    LumenPalette p, {
    Brightness brightness = Brightness.dark,
    LumenStyle style = LumenStyle.neon,
  }) {
    Color foregroundOn(Color fill) =>
        lumenContrastingForeground(<Color>[fill], backdrop: p.surface, palette: p);

    final scheme = ColorScheme.fromSeed(
      dynamicSchemeVariant: .vibrant,
      brightness: brightness,
      seedColor: p.primary,
      primary: p.primary,
      secondary: p.secondary,
      tertiary: p.tertiary,
      surface: p.surface,
      onPrimary: foregroundOn(p.primary),
      onSecondary: foregroundOn(p.secondary),
      onTertiary: foregroundOn(p.tertiary),
      onSurface: p.textPrimary,
      error: p.danger,
      onError: foregroundOn(p.danger),
    );

    final textTheme = TextTheme(
      displaySmall: TextStyle(
        color: p.textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
      headlineMedium: TextStyle(
        color: p.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      ),
      titleLarge: TextStyle(
        color: p.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
      titleMedium: TextStyle(color: p.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(color: p.textSecondary, fontSize: 14, height: 1.45),
      bodySmall: TextStyle(color: p.textMuted, fontSize: 12, letterSpacing: 0.6),
      labelLarge: TextStyle(
        color: p.primary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.6,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.backgroundDeep,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: p.textPrimary,
      ),
      iconTheme: IconThemeData(color: p.primary),
      dividerColor: p.surfaceOutline,
      extensions: <ThemeExtension<dynamic>>[LumenThemeExt(palette: p, style: style)],
    );
  }
}
