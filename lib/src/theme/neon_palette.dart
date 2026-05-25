import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Paleta instanciável do tema neon. Permite criar variantes (ex. branca, com
/// outras accents) sem alterar os tokens default de [AppColors].
@immutable
class NeonPalette {
  /// Cria uma paleta completa para o tema neon.
  ///
  /// Todos os tokens são obrigatórios para manter os widgets independentes de
  /// fallbacks globais e permitir temas alternativos consistentes.
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

  /// Tom mais profundo do fundo da aplicação.
  final Color backgroundDeep;

  /// Tom intermediário usado em gradientes de fundo.
  final Color backgroundMid;

  /// Tom mais claro do fundo, usado para suavizar o gradiente.
  final Color backgroundSoft;

  /// Cor base para cards, overlays e superfícies elevadas.
  final Color surface;

  /// Contorno translúcido usado em bordas de superfícies.
  final Color surfaceOutline;

  /// Realce sutil aplicado dentro de superfícies translúcidas.
  final Color surfaceHighlight;

  /// Accent primário usado em bordas, ícones e estados ativos.
  final Color accentCyan;

  /// Accent secundário usado em glows e composições de gradiente.
  final Color accentMagenta;

  /// Accent intermediário que conecta cyan e magenta nos gradientes.
  final Color accentBlue;

  /// Cor de maior contraste para títulos e conteúdo principal.
  final Color textPrimary;

  /// Cor de contraste médio para textos de apoio.
  final Color textSecondary;

  /// Cor de menor contraste para legendas, hints e conteúdo auxiliar.
  final Color textMuted;

  /// Cor semântica para estados de sucesso.
  final Color success;

  /// Cor semântica para estados de alerta.
  final Color warning;

  /// Cor semântica para estados de erro ou perigo.
  final Color danger;

  /// Gradiente padrão de fundo da aplicação.
  final LinearGradient backgroundGradient;

  /// Gradiente de destaque usado em CTAs, indicadores e elementos ativos.
  final LinearGradient accentGradient;

  /// Retorna uma nova paleta preservando os tokens não informados.
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
  }) => NeonPalette(
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
  /// Cria uma extensão de tema que transporta a [palette].
  const NeonThemeExt({required this.palette});

  /// Paleta disponível para os widgets que leem o [ThemeData] atual.
  final NeonPalette palette;

  /// Obtém a extensão neon registrada no [Theme] mais próximo.
  ///
  /// Falha em modo debug se [NeonThemeExt] não tiver sido adicionada ao
  /// [ThemeData.extensions].
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
