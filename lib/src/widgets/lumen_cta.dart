import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_action_content.dart';
import '../foundation/lumen_pressable.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Primary CTA with a neon gradient. Reused across screens.
class LumenCta extends StatelessWidget {
  /// Creates a primary CTA with a gradient.
  const LumenCta({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.busy = false,
    this.gradient,
    this.glowColor,
    this.foregroundColor,
    this.borderRadius = 14,
  });

  /// Text displayed on the CTA.
  final String label;

  /// Callback run when the CTA is tapped.
  ///
  /// When `null`, the CTA appears disabled.
  final VoidCallback? onPressed;

  /// Optional icon displayed before [label].
  final IconData? icon;

  /// If `true`, displays a progress indicator and blocks taps.
  final bool busy;

  /// Button gradient. Default: `palette.accentGradient`.
  final Gradient? gradient;

  /// Glow color (boxShadow). Default: `palette.secondary`.
  final Color? glowColor;

  /// Text/icon color. Default: `palette.backgroundDeep`.
  final Color? foregroundColor;

  /// Button corner radius in logical pixels.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final bool enabled = onPressed != null && !busy;
    final Gradient g = gradient ?? p.accentGradient;
    final Color glow = glowColor ?? p.secondary;
    final Color fg = foregroundColor ?? p.backgroundDeep;

    return LumenPressable(
      onTap: onPressed,
      enabled: !busy,
      borderRadius: style.radius(borderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          gradient: style.fill(g),
          borderRadius: style.radius(borderRadius),
          boxShadow: style.shadows(
            enabled
                ? <BoxShadow>[
                    BoxShadow(
                      color: glow.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
        ),
        child: LumenActionContent(
          color: fg,
          label: label,
          icon: icon,
          busy: busy,
        ),
      ),
    );
  }
}
