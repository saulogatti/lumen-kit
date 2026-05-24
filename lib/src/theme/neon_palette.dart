import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Paleta instanciável do tema neon. Permite criar variantes (ex. branca, com
/// outras accents) sem alterar os tokens default de [AppColors].
@immutable
class NeonPalette {
  const NeonPalette({
    required this.backgroundDeep,
    required this.backgroundMid,
    required this.backgroundSoft,
    required this.surface,
    required this.surfaceOutline,
    required this.surfaceHighlight,
    required this.accentCyan,
    required this.accentMagenta,
    required this.accentBlue,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.danger,
    required this.backgroundGradient,
    required this.accentGradient,
  });

  /// Paleta default — mesmas cores expostas em [AppColors].
  factory NeonPalette.defaultDark() => const NeonPalette(
        backgroundDeep: AppColors.backgroundDeep,
        backgroundMid: AppColors.backgroundMid,
        backgroundSoft: AppColors.backgroundSoft,
        surface: AppColors.surface,
        surfaceOutline: AppColors.surfaceOutline,
        surfaceHighlight: AppColors.surfaceHighlight,
        accentCyan: AppColors.accentCyan,
        accentMagenta: AppColors.accentMagenta,
        accentBlue: AppColors.accentBlue,
        textPrimary: AppColors.textPrimary,
        textSecondary: AppColors.textSecondary,
        textMuted: AppColors.textMuted,
        success: AppColors.success,
        warning: AppColors.warning,
        danger: AppColors.danger,
        backgroundGradient: AppColors.backgroundGradient,
        accentGradient: AppColors.accentGradient,
      );

  final Color backgroundDeep;
  final Color backgroundMid;
  final Color backgroundSoft;
  final Color surface;
  final Color surfaceOutline;
  final Color surfaceHighlight;
  final Color accentCyan;
  final Color accentMagenta;
  final Color accentBlue;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color success;
  final Color warning;
  final Color danger;
  final LinearGradient backgroundGradient;
  final LinearGradient accentGradient;

  NeonPalette copyWith({
    Color? backgroundDeep,
    Color? backgroundMid,
    Color? backgroundSoft,
    Color? surface,
    Color? surfaceOutline,
    Color? surfaceHighlight,
    Color? accentCyan,
    Color? accentMagenta,
    Color? accentBlue,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? success,
    Color? warning,
    Color? danger,
    LinearGradient? backgroundGradient,
    LinearGradient? accentGradient,
  }) =>
      NeonPalette(
        backgroundDeep: backgroundDeep ?? this.backgroundDeep,
        backgroundMid: backgroundMid ?? this.backgroundMid,
        backgroundSoft: backgroundSoft ?? this.backgroundSoft,
        surface: surface ?? this.surface,
        surfaceOutline: surfaceOutline ?? this.surfaceOutline,
        surfaceHighlight: surfaceHighlight ?? this.surfaceHighlight,
        accentCyan: accentCyan ?? this.accentCyan,
        accentMagenta: accentMagenta ?? this.accentMagenta,
        accentBlue: accentBlue ?? this.accentBlue,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textMuted: textMuted ?? this.textMuted,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        danger: danger ?? this.danger,
        backgroundGradient: backgroundGradient ?? this.backgroundGradient,
        accentGradient: accentGradient ?? this.accentGradient,
      );
}

/// ThemeExtension para acessar a paleta via `Theme.of(context).extension<NeonThemeExt>()`.
@immutable
class NeonThemeExt extends ThemeExtension<NeonThemeExt> {
  const NeonThemeExt({required this.palette});

  final NeonPalette palette;

  static NeonThemeExt of(BuildContext context) {
    final NeonThemeExt? ext = Theme.of(context).extension<NeonThemeExt>();
    assert(ext != null, 'NeonThemeExt não está registrado no ThemeData.');
    return ext!;
  }

  @override
  NeonThemeExt copyWith({NeonPalette? palette}) =>
      NeonThemeExt(palette: palette ?? this.palette);

  @override
  NeonThemeExt lerp(ThemeExtension<NeonThemeExt>? other, double t) {
    if (other is! NeonThemeExt) return this;
    return t < 0.5 ? this : other;
  }
}
