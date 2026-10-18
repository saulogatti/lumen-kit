import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Skeleton/shimmer in neon style.
///
/// Use while the actual content is loading.
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
  const LumenSkeleton.circle({required double size, super.key, this.baseColor, this.highlightColor})
    : width = size,
      height = size,
      borderRadius = 0,
      shape = BoxShape.circle;

  /// Skeleton width.
  ///
  /// When `null`, it occupies the width imposed by the parent.
  final double? width;

  /// Skeleton height.
  final double height;

  /// Corner radius when [shape] is [BoxShape.rectangle].
  final double borderRadius;

  /// Visual shape of the skeleton.
  final BoxShape shape;

  /// Shimmer base color.
  ///
  /// Default: translucent surface of the palette.
  final Color? baseColor;

  /// Animated glow color.
  ///
  /// Default: translucent cyan accent from the palette.
  final Color? highlightColor;

  @override
  State<LumenSkeleton> createState() => _LumenSkeletonState();
}

class _LumenSkeletonState extends State<LumenSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Com "reduzir animações", o brilho fica parado no meio.
    LumenMotion.syncRepeat(_ctrl, context);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final base = widget.baseColor ?? p.surface.withValues(alpha: style.surfaceAlpha(0.55));
    final highlight = widget.highlightColor ?? p.primary.withValues(alpha: 0.25);

    final radius = widget.shape == BoxShape.circle
        ? BorderRadius.zero
        : style.radius(widget.borderRadius);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, _) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) {
            final t = _ctrl.value;
            return LinearGradient(
              begin: Alignment(-1 + 2 * t - 0.3, 0),
              end: Alignment(-1 + 2 * t + 0.3, 0),
              colors: <Color>[Colors.transparent, highlight, Colors.transparent],
              stops: const <double>[0, 0.5, 1],
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
