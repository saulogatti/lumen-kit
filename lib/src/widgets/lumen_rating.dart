import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_pressable.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Rating stars.
///
/// With [onChanged], the user chooses the note by playing; without it, it only
/// displays (including fractional grades, such as 4.3).
/// ```dart
/// LumenRating(value: _nota, onChanged: (double v) => setState(() => _nota = v))
/// LumenRating(value: produto.media) // somente leitura
/// ```
class LumenRating extends StatelessWidget {
  /// Create the assessment.
  const LumenRating({
    required this.value,
    super.key,
    this.onChanged,
    this.max = 5,
    this.allowHalf = false,
    this.size = 28,
    this.spacing = 2,
    this.color,
    this.icon = Icons.star_rounded,
    this.emptyIcon = Icons.star_outline_rounded,
    this.semanticLabel,
  }) : assert(max > 0);

  /// Current score, from 0 to [max].
  ///
  /// Accepts fractions in the display.
  final double value;

  /// Called with the note played.
  ///
  /// `null` = read only.
  final ValueChanged<double>? onChanged;

  /// Number of stars.
  final int max;

  /// Allows you to choose half a star (tap on the left half).
  final bool allowHalf;

  /// Size of each star.
  final double size;

  /// Space between stars.
  final double spacing;

  /// Color of filled stars.
  ///
  /// Default: `palette.warning`.
  final Color? color;

  /// Filled icon.
  final IconData icon;

  /// Empty icon.
  final IconData emptyIcon;

  /// Label for screen readers (e.g.
  ///
  /// "Rating").
  final String? semanticLabel;

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle s = LumenStyle.of(context);
    final Color fill = color ?? p.warning;
    final Color idle = p.textMuted.scaleAlpha(0.6);
    final double current = value.clamp(0, max.toDouble());
    final double step = allowHalf ? 0.5 : 1;
    final interactive = onChanged != null;
    final List<Shadow>? glow = s.shadow == LumenShadowKind.glow
        ? <Shadow>[
            Shadow(
              color: fill.withValues(alpha: 0.6 * s.shadowStrength),
              blurRadius: 10,
            ),
          ]
        : null;

    Widget star(int i) {
      final double f = (current - i).clamp(0.0, 1.0);
      final Widget body = SizedBox.square(
        dimension: size,
        child: Stack(
          children: <Widget>[
            Icon(emptyIcon, size: size, color: idle),
            if (f > 0)
              ClipRect(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: f,
                  child: Icon(icon, size: size, color: fill, shadows: glow),
                ),
              ),
          ],
        ),
      );
      if (!interactive) {
        return body;
      }

      final r = BorderRadius.circular(size / 2);
      if (!allowHalf) {
        return LumenPressable(
          onTap: () => onChanged!(i + 1.0),
          customBorder: const CircleBorder(),
          child: body,
        );
      }
      return Stack(
        children: <Widget>[
          body,
          Positioned.fill(
            child: Row(
              children: <Widget>[
                for (final double v in <double>[i + 0.5, i + 1.0])
                  Expanded(
                    child: LumenPressable(
                      onTap: () => onChanged!(v),
                      borderRadius: r,
                      child: const SizedBox.expand(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    final double up = (current + step).clamp(0, max.toDouble());
    final double down = (current - step).clamp(0, max.toDouble());
    return Semantics(
      container: true,
      label: semanticLabel,
      value: '${_fmt(current)}/$max',
      increasedValue: interactive && up != current ? '${_fmt(up)}/$max' : null,
      decreasedValue: interactive && down != current
          ? '${_fmt(down)}/$max'
          : null,
      onIncrease: interactive && up != current ? () => onChanged!(up) : null,
      onDecrease: interactive && down != current
          ? () => onChanged!(down)
          : null,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: spacing,
          children: <Widget>[for (int i = 0; i < max; i++) star(i)],
        ),
      ),
    );
  }
}
