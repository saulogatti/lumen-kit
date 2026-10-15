import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Tooltip styled with the neon identity (translucent surface, accent border
/// + glow). Thin wrapper around Material's [Tooltip].
class LumenTooltip extends StatelessWidget {
  /// Creates a neon tooltip around [child].
  const LumenTooltip({
    required this.message,
    required this.child,
    super.key,
    this.accentColor,
    this.waitDuration = const Duration(milliseconds: 300),
    this.showDuration = const Duration(milliseconds: 1800),
    this.preferBelow,
  });

  /// Message displayed by the tooltip.
  final String message;

  /// Widget that triggers the tooltip.
  final Widget child;

  /// Accent color override. Default: `palette.primary`.
  final Color? accentColor;

  /// Delay before displaying the tooltip.
  final Duration waitDuration;

  /// How long the tooltip remains visible.
  final Duration showDuration;

  /// Position preference passed to [Tooltip].
  final bool? preferBelow;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final Color accent = accentColor ?? p.primary;

    return Tooltip(
      message: message,
      waitDuration: waitDuration,
      showDuration: showDuration,
      preferBelow: preferBelow,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      textStyle: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: p.textPrimary),
      decoration: LumenDecorations.panel(
        p,
        style,
        accent: accent,
        radius: 10,
        borderWidth: 1,
        glowBlur: 14,
        glowOffset: const Offset(0, 6),
      ),
      child: child,
    );
  }
}
