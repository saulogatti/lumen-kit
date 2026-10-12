import 'package:material_ui/material_ui.dart';

import 'neon_palette.dart';

/// Tema central da aplicação. Mantém ThemeData isolado da camada de UI
/// para que telas não conheçam detalhes de estilo globais.
class AppTheme {
  /// Tema dark default usando a paleta padrão.
  static ThemeData get dark =>
      fromPalette(NeonPalette.defaultDark(), brightness: Brightness.dark);
  static ThemeData get light =>
      fromPalette(NeonPalette.light(), brightness: Brightness.light);
  const AppTheme._();

  /// Constrói um [ThemeData] dark a partir da paleta [p].
  ///
  /// Registra [NeonThemeExt] em [ThemeData.extensions] para que os widgets do
  /// kit acessem os mesmos tokens via [NeonThemeExt.of].
  static ThemeData fromPalette(
    NeonPalette p, {
    Brightness brightness = Brightness.light,
  }) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      dynamicSchemeVariant: .vibrant,
      brightness: brightness,
      seedColor: p.accentCyan,
      primary: p.accentCyan,
      secondary: p.accentMagenta,
      surface: p.surface,
      onPrimary: p.backgroundDeep,
      onSecondary: p.textPrimary,
      onSurface: p.textPrimary,
      error: p.danger,
      onError: p.textPrimary,
    );

    final TextTheme textTheme = TextTheme(
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
        color: p.accentCyan,
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
      iconTheme: IconThemeData(color: p.accentCyan),
      dividerColor: p.surfaceOutline,
      extensions: <ThemeExtension<dynamic>>[NeonThemeExt(palette: p)],
    );
  }
}
