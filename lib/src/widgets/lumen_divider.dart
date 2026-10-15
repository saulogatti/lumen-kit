import 'package:material_ui/material_ui.dart';

import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Divider with an accent gradient that fades at the ends. Supports
/// horizontal (default) or vertical orientation, and an optional centered
/// [label].
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

  /// Space before the line along the main axis.
  final double indent;

  /// Space after the line along the main axis.
  final double endIndent;

  /// If `true`, draws the divider vertically.
  final bool vertical;

  /// Centered text, displayed only in horizontal mode.
  final String? label;

  /// Accent color override. Default: `palette.primary`.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final Color accent = accentColor ?? p.primary;
    final colors = <Color>[
      accent.withValues(alpha: 0),
      accent.withValues(alpha: 0.65),
      p.secondary.withValues(alpha: 0.65),
      accent.withValues(alpha: 0),
    ];

    if (vertical) {
      return Padding(
        padding: EdgeInsets.only(top: indent, bottom: endIndent),
        child: Container(
          width: thickness,
          decoration: BoxDecoration(
            gradient: style.fill(
              LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: colors,
              ),
            ),
          ),
        ),
      );
    }

    final Widget line = Container(
      height: thickness,
      decoration: BoxDecoration(
        gradient: style.fill(LinearGradient(colors: colors)),
      ),
    );

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
