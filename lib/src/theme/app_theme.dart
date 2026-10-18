import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Central theme of the application.
///
/// Keeps ThemeData isolated from the UI layer so that screens do not know
/// global style details.
class AppTheme {
  const AppTheme._();

  /// Default dark theme using the default palette.
  static ThemeData get dark => fromPalette(LumenPalette.defaultDark());

  /// Light theme using the default light palette.
  static ThemeData get light => fromPalette(LumenPalette.light(), brightness: Brightness.light);

  /// Shortcut to change the colors of the entire kit from one or two colors.
  ///
  /// Equivalent to `fromPalette(LumenPalette.fromSeed(...))`.
  static ThemeData fromSeed({
    required Color primary,
    Color? secondary,
    Color? tertiary,
    Brightness brightness = Brightness.dark,
    LumenStyle style = LumenStyle.neon,
  }) => fromPalette(
    LumenPalette.fromSeed(
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      brightness: brightness,
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

  /// Builds a [ThemeData] from the [p] palette.
  /// Registers [LumenThemeExt] to [ThemeData.extensions] so that the widgets kit
  /// access the same tokens via [LumenThemeExt.of].
  static ThemeData fromPalette(
    LumenPalette p, {
    Brightness brightness = Brightness.dark,
    LumenStyle style = LumenStyle.neon,
  }) {
    final scheme = ColorScheme.fromSeed(
      dynamicSchemeVariant: .vibrant,
      brightness: brightness,
      seedColor: p.primary,
      primary: p.primary,
      secondary: p.secondary,
      surface: p.surface,
      onPrimary: p.backgroundDeep,
      onSecondary: p.textPrimary,
      onSurface: p.textPrimary,
      error: p.danger,
      onError: p.textPrimary,
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
