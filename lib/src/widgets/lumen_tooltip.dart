import 'package:lumen_kit/src/foundation/lumen_decorations.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Stylized tooltip following the neon identity (translucent surface, accent +
/// glow).
///
/// Thin wrapper over the Material [Tooltip].
class LumenTooltip extends StatelessWidget {
  /// Creates a neon tooltip to wrap around [child].
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

  /// Widget that triggers the tooltip display.
  final Widget child;

  /// Highlight color override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Waiting time before displaying the tooltip.
  final Duration waitDuration;

  /// Time the tooltip remains visible.
  final Duration showDuration;

  /// Positioning preference passed on to [Tooltip].
  final bool? preferBelow;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final accent = accentColor ?? p.primary;

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
