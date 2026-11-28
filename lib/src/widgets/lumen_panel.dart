import 'package:lumen_kit/src/foundation/lumen_decorations.dart';
import 'package:lumen_kit/src/foundation/lumen_pressable.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Decorative layers a [LumenPanel] can draw behind its content.
enum LumenPanelEffect {
  /// Line grid in the accent color.
  grid,

  /// Dot grid in the accent color.
  dots,

  /// Soft light in the accent color at the top right corner.
  ///
  /// Skipped when [LumenStyle.gradients] is `false`.
  orb,

  /// Border painted with the accent gradient instead of a single color.
  ///
  /// Falls back to the plain accent border when [LumenStyle.gradients] is
  /// `false`.
  gradientBorder,

  /// Glow around the panel, adapted by [LumenStyle.shadows].
  glow,
}

/// Background surface for a group of components, with optional decorative
/// [effects] drawn behind the content.
///
/// Without effects it is a plain themed surface, like `LumenCard`. Each
/// [LumenPanelEffect] adds one layer: a grid or dots pattern, a corner orb, a
/// gradient border, an outer glow. The layers ignore pointers and clip to the
/// panel's corners.
///
/// ```dart
/// LumenPanel(
///   effects: const <LumenPanelEffect>{.grid, .orb, .gradientBorder},
///   child: Column(
///     children: <Widget>[
///       const Text('Sales today'),
///       LumenButton(label: 'Open', onPressed: open),
///     ],
///   ),
/// )
/// ```
class LumenPanel extends StatelessWidget {
  /// Creates a panel with [child] over the chosen [effects].
  const LumenPanel({
    required this.child,
    super.key,
    this.effects = const <LumenPanelEffect>{},
    this.accentColor,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.patternSpacing = 28,
    this.onTap,
  }) : assert(patternSpacing > 0, 'patternSpacing must be greater than zero.');

  /// Content displayed over the effects.
  final Widget child;

  /// Decorative layers to draw. Empty by default.
  ///
  /// [LumenPanelEffect.grid] wins when it is combined with
  /// [LumenPanelEffect.dots].
  final Set<LumenPanelEffect> effects;

  /// Color of the border and the effects.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Internal spacing applied to [child].
  final EdgeInsetsGeometry padding;

  /// Radius of the panel's corners in logical pixels.
  final double borderRadius;

  /// Distance in logical pixels between grid lines; dots use half of it.
  final double patternSpacing;

  /// Callback executed when touching the panel.
  ///
  /// When `null`, the panel is rendered without interactive behavior.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final accent = accentColor ?? p.primary;
    final radius = style.radius(borderRadius);
    bool has(LumenPanelEffect effect) => effects.contains(effect);

    final pattern = has(.grid) || has(.dots);
    final orb = has(.orb) && style.gradients;
    final gradientBorder = has(.gradientBorder) && style.gradients && style.borderScale > 0;

    Widget content = Padding(padding: padding, child: child);
    if (pattern || orb) {
      content = ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            if (pattern)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _PatternPainter(
                      spacing: patternSpacing,
                      color: accent.withValues(alpha: 0.07),
                      dots: !has(.grid),
                    ),
                  ),
                ),
              ),
            if (orb)
              Positioned(
                top: -70,
                right: -70,
                child: IgnorePointer(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: <Color>[
                          accent.withValues(alpha: 0.22),
                          accent.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            content,
          ],
        ),
      );
    }

    final surface = style.frost(
      borderRadius: radius,
      child: CustomPaint(
        foregroundPainter: gradientBorder
            ? _GradientBorderPainter(
                gradient: LumenDecorations.accent(p, accent),
                radius: radius,
                width: 1.2 * style.borderScale,
                opacity: (0.8 * style.borderOpacity).clamp(0, 1),
              )
            : null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: style.fill(
              LumenDecorations.diagonal(
                p.surface.withValues(alpha: style.surfaceAlpha(0.95)),
                p.backgroundMid.withValues(alpha: style.surfaceAlpha(0.85)),
              ),
            ),
            border: gradientBorder
                ? null
                : style.borderAll(color: accent.withValues(alpha: 0.35), width: 1.2),
          ),
          child: content,
        ),
      ),
    );

    final body = onTap == null
        ? surface
        : LumenPressable(onTap: onTap, borderRadius: radius, mergeSemantics: false, child: surface);

    if (!has(.glow)) {
      return body;
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: style.shadows(<BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ]),
      ),
      child: body,
    );
  }
}

class _PatternPainter extends CustomPainter {
  final double spacing;
  final Color color;
  final bool dots;

  const _PatternPainter({required this.spacing, required this.color, required this.dots});

  @override
  void paint(Canvas canvas, Size size) {
    // The constructor asserts this in debug; in release a zero step would
    // loop forever, so skip the pattern instead.
    if (spacing <= 0 || !spacing.isFinite) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    if (dots) {
      // Dots are subtler than lines; compensate with opacity.
      paint.color = color.scaleAlpha(3);
      for (var x = spacing / 2; x < size.width; x += spacing / 2) {
        for (var y = spacing / 2; y < size.height; y += spacing / 2) {
          canvas.drawCircle(Offset(x, y), 1.2, paint);
        }
      }
      return;
    }
    for (var x = spacing; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_PatternPainter oldDelegate) =>
      spacing != oldDelegate.spacing || color != oldDelegate.color || dots != oldDelegate.dots;
}

class _GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final BorderRadius radius;
  final double width;
  final double opacity;

  const _GradientBorderPainter({
    required this.gradient,
    required this.radius,
    required this.width,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..shader = gradient.withOpacity(opacity).createShader(rect);
    // Inset by half the stroke so the border stays inside the panel.
    canvas.drawRRect(radius.toRRect(rect).deflate(width / 2), paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter oldDelegate) =>
      gradient != oldDelegate.gradient ||
      radius != oldDelegate.radius ||
      width != oldDelegate.width ||
      opacity != oldDelegate.opacity;
}
