import 'package:lumen_kit/src/foundation/lumen_decorations.dart';
import 'package:lumen_kit/src/foundation/lumen_pressable.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Neon theme base container: subtle gradient + accent border + optional onTap.
///
/// Use as a fundamental piece for any screen — cards, panels, sections.
class LumenCard extends StatelessWidget {
  /// Creates a neon card with [child] as content.
  const LumenCard({
    required this.child,
    super.key,
    this.accent,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.onTap,
    this.borderOpacity = 0.35,
    this.glow = false,
  });

  /// Content displayed inside the card.
  final Widget child;

  /// Highlight color (border + glow).
  ///
  /// Default: `palette.primary`.
  final Color? accent;

  /// Internal spacing applied to [child].
  final EdgeInsetsGeometry padding;

  /// Radius of the card's corners in logical pixels.
  final double borderRadius;

  /// Callback executed when touching the card.
  /// When `null`, the card is rendered without interactive behavior.
  final VoidCallback? onTap;

  /// Highlight border opacity.
  final double borderOpacity;

  /// Whether to add a slight glow around the card.
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final a = accent ?? p.primary;
    final radius = style.radius(borderRadius);

    final content = style.frost(
      borderRadius: radius,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: style.fill(
            LumenDecorations.diagonal(
              p.surface.withValues(alpha: style.surfaceAlpha(0.95)),
              p.backgroundMid.withValues(alpha: style.surfaceAlpha(0.85)),
            ),
          ),
          border: style.borderAll(
            color: a.withValues(alpha: borderOpacity),
            width: 1.2,
          ),
        ),
        child: child,
      ),
    );

    final body = onTap == null
        ? content
        : LumenPressable(
            onTap: onTap,
            borderRadius: radius,
            mergeSemantics: false,
            child: content,
          );

    if (!glow) {
      return body;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: style.shadows(<BoxShadow>[
          BoxShadow(
            color: a.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ]),
      ),
      child: body,
    );
  }
}
