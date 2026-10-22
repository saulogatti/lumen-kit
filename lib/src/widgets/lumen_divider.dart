import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Gradient accent divider that fades at the ends.
///
/// Supports guidance horizontal (default) or vertical, and an optional
/// centralized [label].
class LumenDivider extends StatelessWidget {
  /// Creates a horizontal or vertical neon divider.
  const LumenDivider({
    super.key,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.vertical = false,
    this.label,
    this.accentColor,
  });

  /// Line thickness in logical pixels.
  final double thickness;

  /// Space before the line on the main axis.
  final double indent;

  /// Space after the line on the main axis.
  final double endIndent;

  /// Whether to draw the divider vertically.
  final bool vertical;

  /// Center text displayed in landscape mode only.
  final String? label;

  /// Highlight color override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final accent = accentColor ?? p.primary;
    final colors = <Color>[
      accent.withValues(alpha: 0),
      accent.withValues(alpha: 0.65),
      p.secondary.withValues(alpha: 0.65),
      accent.withValues(alpha: 0),
    ];

    // Sem gradientes, style.fill ficaria só com a primeira parada, que é
    // transparente, e a linha sumiria: vira o acento sólido a 65%.
    BoxDecoration decoration({
      Alignment begin = Alignment.centerLeft,
      Alignment end = Alignment.centerRight,
    }) => style.gradients
        ? BoxDecoration(
            gradient: LinearGradient(begin: begin, end: end, colors: colors),
          )
        : BoxDecoration(color: accent.withValues(alpha: 0.65));

    if (vertical) {
      return Padding(
        padding: EdgeInsets.only(top: indent, bottom: endIndent),
        child: Container(
          width: thickness,
          decoration: decoration(begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
      );
    }

    final Widget line = Container(height: thickness, decoration: decoration());

    if (label == null) {
      return Padding(
        padding: EdgeInsets.only(left: indent, right: endIndent),
        child: line,
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: indent, right: endIndent),
      child: Row(
        children: <Widget>[
          Expanded(child: line),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label!,
              style: TextStyle(
                color: p.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(child: line),
        ],
      ),
    );
  }
}
