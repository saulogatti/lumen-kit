import 'package:material_ui/material_ui.dart';

import 'neon_palette.dart';
import 'neon_style.dart';

/// Tema central da aplicação. Mantém ThemeData isolado da camada de UI
/// para que telas não conheçam detalhes de estilo globais.
class AppTheme {
  const AppTheme._();

  /// Tema dark default usando a paleta padrão.
  static ThemeData get dark => fromPalette(NeonPalette.defaultDark());

  /// Tema claro usando a paleta clara padrão.
  static ThemeData get light =>
      fromPalette(NeonPalette.light(), brightness: Brightness.light);

  /// Atalho para trocar as cores do kit inteiro a partir de uma ou duas
  /// cores. Equivale a `fromPalette(NeonPalette.fromSeed(...))`.
  static ThemeData fromSeed({
    required Color primary,
    Color? secondary,
    Color? tertiary,
    Brightness brightness = Brightness.dark,
    NeonStyle style = NeonStyle.neon,
  }) => fromPalette(
    NeonPalette.fromSeed(
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      brightness: brightness,
    ),
    brightness: brightness,
    style: style,
  );

  /// Atalho para usar um [NeonPreset].
  static ThemeData fromPreset(
    NeonPreset preset, {
    Brightness brightness = Brightness.dark,
    NeonStyle style = NeonStyle.neon,
  }) => fromPalette(
    preset.palette(brightness: brightness),
    brightness: brightness,
    style: style,
  );

  /// Constrói um [ThemeData] a partir da paleta [p].
  ///
  /// Registra [NeonThemeExt] em [ThemeData.extensions] para que os widgets do
  /// kit acessem os mesmos tokens via [NeonThemeExt.of].
  static ThemeData fromPalette(
    NeonPalette p, {
    Brightness brightness = Brightness.dark,
    NeonStyle style = NeonStyle.neon,
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
      titleMedium: TextStyle(
        color: p.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(color: p.textSecondary, fontSize: 14, height: 1.45),
      bodySmall: TextStyle(
        color: p.textMuted,
        fontSize: 12,
        letterSpacing: 0.6,
      ),
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
      extensions: <ThemeExtension<dynamic>>[
        NeonThemeExt(palette: p, style: style),
      ],
    );
  }
}
