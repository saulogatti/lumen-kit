import 'package:lumen_kit/src/foundation/lumen_action_content.dart';
import 'package:lumen_kit/src/foundation/lumen_pressable.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Primary CTA with neon gradient.
///
/// Reused on all screens.
class LumenCta extends StatelessWidget {
  /// Create a primary CTA with a gradient.
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

  /// Text displayed in the CTA.
  final String label;

  /// Callback executed when tapping the CTA.
  /// When `null`, the CTA is visually disabled.
  final VoidCallback? onPressed;

  /// Optional icon displayed before [label].
  final IconData? icon;

  /// Whether to display progress indicator and blocks ringing.
  final bool busy;

  /// Button gradient.
  ///
  /// Default: `palette.accentGradient`.
  final Gradient? gradient;

  /// Glow color (boxShadow).
  ///
  /// Default: `palette.secondary`.
  final Color? glowColor;

  /// Text/icon color.
  ///
  /// Default: `palette.backgroundDeep`.
  final Color? foregroundColor;

  /// Radius of button corners in logical pixels.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final enabled = onPressed != null && !busy;
    final g = gradient ?? p.accentGradient;
    final glow = glowColor ?? p.secondary;
    final fg = foregroundColor ?? p.backgroundDeep;

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
