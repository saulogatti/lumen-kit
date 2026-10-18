import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Decorations shared by kit widgets.
///
/// They all go through [LumenStyle], so they change along with the style (neon,
/// flat, glass…).
/// Useful for building your own components with the same look as the kit:
/// ```dart
/// final LumenPalette p = LumenThemeExt.of(context).palette;
/// final LumenStyle s = LumenStyle.of(context);
/// Container(decoration: LumenDecorations.panel(p, s, accent: p.secondary));
/// ```
abstract final class LumenDecorations {
  /// Diagonal gradient (top-left → bottom-right) from [a] to [b].
  static LinearGradient diagonal(Color a, Color b) =>
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[a, b]);

  /// Diagonal accent gradient for `palette.secondary`, used in active markers
  /// (checkbox, radio, switch, avatar, stepper…).
  static LinearGradient accent(LumenPalette p, Color accent) => diagonal(accent, p.secondary);

  /// Floating panel: gradient surface, border and glow in [accent].
  ///
  /// Dialog base, tooltip, snackbar, toast and cards.
  static BoxDecoration panel(
    LumenPalette p,
    LumenStyle s, {
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

  /// Selectable item (drawer, navigation, list tile): background and border
  /// [accent] glows when [selected]; transparent when not.
  static BoxDecoration selectable(
    LumenPalette p,
    LumenStyle s, {
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
      color: selected ? accent.withValues(alpha: borderAlpha) : Colors.transparent,
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

  /// Icon in translucent box in [accent] (dialog header, cards).
  static BoxDecoration iconBox(
    LumenStyle s, {
    required Color accent,
    double radius = 12,
    double fillAlpha = 0.12,
    double borderAlpha = 0.45,
  }) => BoxDecoration(
    borderRadius: s.radius(radius),
    color: accent.withValues(alpha: fillAlpha),
    border: s.borderAll(color: accent.withValues(alpha: borderAlpha)),
  );

  /// Text field decoration (text field, search, dropdown, date).
  static InputDecoration input(
    LumenPalette p,
    LumenStyle s, {
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
    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
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
      disabledBorder: border(p.surfaceOutline.outlineAlpha(0.5)),
      focusedBorder: border(accent, 1.4),
      errorBorder: border(p.danger),
      focusedErrorBorder: border(p.danger, 1.4),
    );
  }
}
