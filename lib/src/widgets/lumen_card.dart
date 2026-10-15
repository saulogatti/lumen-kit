import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../foundation/lumen_pressable.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Base container for the neon theme: subtle gradient + accent border +
/// optional `onTap`. Use as a building block for any screen — cards, panels,
/// sections.
class LumenCard extends StatelessWidget {
  /// Creates a neon card with [child] as its content.
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

  /// Accent color (border + glow). Default: `palette.primary`.
  final Color? accent;

  /// Inner spacing applied to [child].
  final EdgeInsetsGeometry padding;

  /// Card corner radius in logical pixels.
  final double borderRadius;

  /// Callback run when the card is tapped.
  ///
  /// When `null`, the card is rendered without interactive behavior.
  final VoidCallback? onTap;

  /// Opacity of the accent border.
  final double borderOpacity;

  /// If `true`, adds a subtle glow around the card.
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final Color a = accent ?? p.primary;
    final BorderRadius radius = style.radius(borderRadius);

    final Widget content = style.frost(
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

    final Widget body = onTap == null
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
