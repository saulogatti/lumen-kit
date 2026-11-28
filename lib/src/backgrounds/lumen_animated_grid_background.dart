import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Old name of [LumenAnimatedGridBackground].
@Deprecated('Use LumenAnimatedGridBackground')
typedef AnimatedGridBackground = LumenAnimatedGridBackground;

/// Old name of [LumenGlowOrbSpec].
@Deprecated('Use LumenGlowOrbSpec')
typedef GlowOrbSpec = LumenGlowOrbSpec;

/// Decorative backdrop with futuristic grid, gradient and glow orbs.
///
/// Fully configurable — defaults reproduce the original look of the theme.
///
/// With bounded constraints, the background and [child] fill the available
/// space, as a screen or app backdrop. In an axis without a bound (inside a
/// [Column], [Row], [ListView] or [SingleChildScrollView]), [child] sets the
/// size in that axis and the background covers it.
class LumenAnimatedGridBackground extends StatelessWidget {
  /// Content rendered above the gradient, grid and orbs.
  final Widget child;

  /// Background gradient.
  ///
  /// Default: `palette.backgroundGradient`.
  final Gradient? gradient;

  /// Orb list.
  ///
  /// Default: `palette.primary` in the upper right corner and `palette.secondary`
  /// at bottom left, or none when [LumenStyle.orbs] is `false`.
  final List<LumenGlowOrbSpec>? orbs;

  /// Distance in px between grid lines. Must be greater than zero.
  final double gridSpacing;

  /// Color of the grid lines.
  ///
  /// Default: `palette.primary`.
  final Color? gridColor;

  /// Opacity of the grid lines (0..1).
  final double gridOpacity;

  /// If `false`, omits the grid/points and only keeps gradient + orbs.
  ///
  /// The type of decoration (grid, dots or none) comes from
  /// [LumenStyle.background].
  final bool showGrid;

  /// Creates a decorative background to surround [child].
  ///
  /// [child] fills bounded axes and determines the size on unbounded axes.
  /// [key] identifies this widget in the tree. When [gradient] is null, the
  /// current palette's background gradient is used. When [orbs] is null,
  /// default primary and secondary orbs are shown if the current style enables
  /// them; an explicit list, including an empty one, overrides that choice.
  ///
  /// [showGrid] defaults to true, but the current style still chooses a grid,
  /// dots, or no pattern. [gridSpacing] defaults to 56 logical pixels and
  /// must be positive. [gridColor] defaults to the palette's primary color;
  /// [gridOpacity] defaults to 0.05 and must be between 0 and 1.
  const LumenAnimatedGridBackground({
    required this.child,
    super.key,
    this.gradient,
    this.orbs,
    this.gridSpacing = 56,
    this.gridColor,
    this.gridOpacity = 0.05,
    this.showGrid = true,
  }) : assert(gridSpacing > 0, 'gridSpacing must be greater than zero.'),
       assert(gridOpacity >= 0 && gridOpacity <= 1, 'gridOpacity must be between 0 and 1.');

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final orbList = orbs ?? (style.orbs ? _defaultOrbs(p) : const <LumenGlowOrbSpec>[]);
    final drawPattern = showGrid && style.background != LumenBackgroundKind.plain;
    final effectiveGridColor = gridColor ?? p.primary;
    final effectiveGradient = gradient ?? p.backgroundGradient;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: effectiveGradient),
      // The child is the only non-positioned entry, so it sizes the stack.
      // A stack of positioned entries alone takes the largest size it is
      // allowed, which is infinite inside a Column, Row or scroll view.
      child: Stack(
        children: <Widget>[
          if (drawPattern)
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(
                  spacing: gridSpacing,
                  color: effectiveGridColor.withValues(alpha: gridOpacity),
                  dots: style.background == LumenBackgroundKind.dots,
                ),
              ),
            ),
          for (final LumenGlowOrbSpec spec in orbList)
            Positioned(
              top: spec.top,
              right: spec.right,
              bottom: spec.bottom,
              left: spec.left,
              child: _GlowOrb(spec: spec),
            ),
          _FillBoundedAxes(child: child),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Gradient?>('gradient', gradient));
    properties.add(IterableProperty<LumenGlowOrbSpec>('orbs', orbs));
    properties.add(DoubleProperty('gridSpacing', gridSpacing));
    properties.add(ColorProperty('gridColor', gridColor));
    properties.add(DoubleProperty('gridOpacity', gridOpacity));
    properties.add(DiagnosticsProperty<bool>('showGrid', showGrid));
  }

  static List<LumenGlowOrbSpec> _defaultOrbs(LumenPalette p) => <LumenGlowOrbSpec>[
    LumenGlowOrbSpec(color: p.primary, size: 320, top: -120, right: -80),
    LumenGlowOrbSpec(color: p.secondary, size: 360, bottom: -160, left: -100),
  ];
}

/// Configuration of a glow orb positioned in the background.
@immutable
class LumenGlowOrbSpec {
  /// Base color used at the center of the radial gradient.
  final Color color;

  /// Orb diameter in logical pixels.
  final double size;

  /// Optional distance to the top of the [Stack].
  final double? top;

  /// Optional distance to the right of [Stack].
  final double? right;

  /// Optional distance to the base of the [Stack].
  final double? bottom;

  /// Optional distance to the left of the [Stack].
  final double? left;

  /// Opacity applied to the center of the orb.
  final double opacity;

  /// Creates a glow orb configuration.
  ///
  /// [color] supplies the center color and [size] is the nonnegative diameter
  /// in logical pixels. [opacity] sets the center's absolute alpha, defaults
  /// to 0.35, and must be between 0 and 1; the gradient fades to transparent.
  /// The optional [top], [right], [bottom], and [left] offsets default to
  /// null and follow [Positioned] layout semantics.
  const LumenGlowOrbSpec({
    required this.color,
    required this.size,
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.opacity = 0.35,
  }) : assert(size >= 0, 'size must not be negative.'),
       assert(opacity >= 0 && opacity <= 1, 'opacity must be between 0 and 1.');
}

/// Gives [child] the full extent of every bounded axis and lets it size
/// itself in an unbounded one.
///
/// Bounded, it matches the old `Positioned.fill`: the child fills the
/// backdrop. Unbounded, a tight constraint would be infinite, so the child's
/// own size is used instead. Intrinsic sizes come from the child.
class _FillBoundedAxes extends SingleChildRenderObjectWidget {
  const _FillBoundedAxes({required Widget super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderFillBoundedAxes();
}

class _RenderFillBoundedAxes extends RenderProxyBox {
  static BoxConstraints _inner(BoxConstraints c) => BoxConstraints(
    minWidth: c.hasBoundedWidth ? c.maxWidth : c.minWidth,
    maxWidth: c.maxWidth,
    minHeight: c.hasBoundedHeight ? c.maxHeight : c.minHeight,
    maxHeight: c.maxHeight,
  );

  @override
  Size computeDryLayout(BoxConstraints constraints) => child!.getDryLayout(_inner(constraints));

  @override
  void performLayout() {
    child!.layout(_inner(constraints), parentUsesSize: true);
    size = child!.size;
  }
}

class _GlowOrb extends StatelessWidget {
  final LumenGlowOrbSpec spec;

  const _GlowOrb({required this.spec});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: spec.size,
        height: spec.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              spec.color.withValues(alpha: spec.opacity),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<LumenGlowOrbSpec>('spec', spec));
  }
}

class _GridPainter extends CustomPainter {
  final double spacing;

  final Color color;

  final bool dots;

  const _GridPainter({required this.spacing, required this.color, required this.dots});

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
      for (double x = 0; x <= size.width; x += spacing / 2) {
        for (double y = 0; y <= size.height; y += spacing / 2) {
          canvas.drawCircle(Offset(x, y), 1.2, paint);
        }
      }
      return;
    }
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) =>
      old.spacing != spacing || old.color != color || old.dots != dots;
}
