import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_tokens.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Skeleton/shimmer in the neon style. Use while real content is loading.
///
/// Examples:
/// ```dart
/// LumenSkeleton(width: 200, height: 14);
/// LumenSkeleton.circle(size: 48);
/// ```
class LumenSkeleton extends StatefulWidget {
  /// Creates a rectangular skeleton.
  const LumenSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius = 8,
    this.baseColor,
    this.highlightColor,
  }) : shape = BoxShape.rectangle;

  /// Creates a circular skeleton with width and height equal to [size].
  const LumenSkeleton.circle({
    super.key,
    required double size,
    this.baseColor,
    this.highlightColor,
  }) : width = size,
       height = size,
       borderRadius = 0,
       shape = BoxShape.circle;

  /// Skeleton width. When `null`, fills the width imposed by the parent.
  final double? width;

  /// Skeleton height.
  final double height;

  /// Corner radius when [shape] is [BoxShape.rectangle].
  final double borderRadius;

  /// Skeleton visual shape.
  final BoxShape shape;

  /// Shimmer base color. Default: translucent palette surface.
  final Color? baseColor;

  /// Animated shimmer color. Default: translucent palette cyan accent.
  final Color? highlightColor;

  @override
  State<LumenSkeleton> createState() => _LumenSkeletonState();
}

class _LumenSkeletonState extends State<LumenSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // With "reduce animations" enabled, the shimmer stays still in the middle.
    LumenMotion.syncRepeat(_ctrl, context);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final Color base =
        widget.baseColor ??
        p.surface.withValues(alpha: style.surfaceAlpha(0.55));
    final Color highlight =
        widget.highlightColor ?? p.primary.withValues(alpha: 0.25);

    final BorderRadius radius = widget.shape == BoxShape.circle
        ? BorderRadius.zero
        : style.radius(widget.borderRadius);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (BuildContext ctx, _) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect rect) {
            final double t = _ctrl.value;
            return LinearGradient(
              begin: Alignment(-1 + 2 * t - 0.3, 0),
              end: Alignment(-1 + 2 * t + 0.3, 0),
              colors: <Color>[
                Colors.transparent,
                highlight,
                Colors.transparent,
              ],
              stops: const <double>[0.0, 0.5, 1.0],
            ).createShader(rect);
          },
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: base,
              shape: widget.shape,
              borderRadius: widget.shape == BoxShape.rectangle ? radius : null,
            ),
          ),
        );
      },
    );
  }
}
