import 'package:material_ui/material_ui.dart';

import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Decorações compartilhadas pelos widgets do kit. Todas passam pelo
/// [NeonStyle], então mudam junto com o estilo (neon, flat, glass…).
///
/// Úteis para construir componentes próprios com a mesma cara do kit:
///
/// ```dart
/// final NeonPalette p = NeonThemeExt.of(context).palette;
/// final NeonStyle s = NeonStyle.of(context);
/// Container(decoration: NeonDecorations.panel(p, s, accent: p.secondary));
/// ```
abstract final class NeonDecorations {
  /// Gradiente diagonal (topo-esquerda → base-direita) de [a] para [b].
  static LinearGradient diagonal(Color a, Color b) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[a, b],
  );

  /// Gradiente diagonal do accent para `palette.secondary`, usado em
  /// marcadores ativos (checkbox, radio, switch, avatar, stepper…).
  static LinearGradient accent(NeonPalette p, Color accent) =>
      diagonal(accent, p.secondary);

  /// Painel flutuante: surface em gradiente, borda e glow no [accent].
  /// Base de dialog, tooltip, snackbar, toast e cards.
  static BoxDecoration panel(
    NeonPalette p,
    NeonStyle s, {
    required Color accent,
    double radius = 14,
    double fromAlpha = 0.98,
    double toAlpha = 0.95,
    double borderAlpha = 0.55,
    double borderWidth = 1.2,
    double glowAlpha = 0.3,
    double glowBlur = 22,
    Offset glowOffset = const Offset(0, 10),
  }) => BoxDecoration(
    borderRadius: s.radius(radius),
    gradient: s.fill(
      diagonal(
        p.surface.withValues(alpha: s.surfaceAlpha(fromAlpha)),
        p.backgroundMid.withValues(alpha: s.surfaceAlpha(toAlpha)),
      ),
    ),
    border: s.borderAll(
      color: accent.withValues(alpha: borderAlpha),
      width: borderWidth,
    ),
    boxShadow: s.shadows(<BoxShadow>[
      BoxShadow(
        color: accent.withValues(alpha: glowAlpha),
        blurRadius: glowBlur,
        offset: glowOffset,
      ),
    ]),
  );

  /// Item selecionável (drawer, navegação, list tile): fundo e borda no
  /// [accent] com glow quando [selected]; transparente quando não.
  static BoxDecoration selectable(
    NeonPalette p,
    NeonStyle s, {
    required Color accent,
    required bool selected,
    double radius = 12,
    double fillAlpha = 0.16,
    double borderAlpha = 0.55,
    double borderWidth = 1,
    double glowAlpha = 0.3,
    double glowBlur = 12,
    double glowSpread = -2,
    bool glow = true,
  }) => BoxDecoration(
    color: selected ? accent.withValues(alpha: fillAlpha) : Colors.transparent,
    borderRadius: s.radius(radius),
    border: s.borderAll(
      color: selected
          ? accent.withValues(alpha: borderAlpha)
          : Colors.transparent,
      width: borderWidth,
    ),
    boxShadow: s.shadows(
      selected && glow
          ? <BoxShadow>[
              BoxShadow(
                color: accent.withValues(alpha: glowAlpha),
                blurRadius: glowBlur,
                spreadRadius: glowSpread,
              ),
            ]
          : null,
    ),
  );

  /// Ícone em caixa translúcida no [accent] (cabeçalho de dialog, cards).
  static BoxDecoration iconBox(
    NeonStyle s, {
    required Color accent,
    double radius = 12,
    double fillAlpha = 0.12,
    double borderAlpha = 0.45,
  }) => BoxDecoration(
    borderRadius: s.radius(radius),
    color: accent.withValues(alpha: fillAlpha),
    border: s.borderAll(color: accent.withValues(alpha: borderAlpha)),
  );

  /// Decoração de campo de texto (text field, busca, dropdown, data).
  static InputDecoration input(
    NeonPalette p,
    NeonStyle s, {
    required Color accent,
    double radius = 12,
    String? label,
    String? hint,
    String? helper,
    String? error,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? contentPadding,
    bool isDense = false,
    double enabledBorderAlpha = 0.35,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: s.radius(radius),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helper,
      errorText: error,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      isDense: isDense,
      filled: true,
      fillColor: p.surface.withValues(alpha: s.surfaceAlpha(0.7)),
      contentPadding: contentPadding,
      labelStyle: TextStyle(color: p.textMuted),
      hintStyle: TextStyle(color: p.textMuted),
      helperStyle: TextStyle(color: p.textMuted),
      enabledBorder: border(accent.withValues(alpha: enabledBorderAlpha)),
      disabledBorder: border(p.surfaceOutline.withValues(alpha: 0.5)),
      focusedBorder: border(accent, 1.4),
      errorBorder: border(p.danger),
      focusedErrorBorder: border(p.danger, 1.4),
    );
  }
}
