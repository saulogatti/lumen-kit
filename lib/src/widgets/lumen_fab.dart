import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_action_content.dart';
import '../foundation/lumen_pressable.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Floating Action Button in neon style.
///
/// It works in two modes:
/// - **Compact** (default, only [icon]) — circle with gradient and glow. -
/// **Extended** (with [label]) — pill with icon + text.
class LumenFab extends StatelessWidget {
  /// Creates a compact or extended FAB when [label] is entered.
  const LumenFab({
    required this.icon,
    required this.onPressed,
    super.key,
    this.label,
    this.busy = false,
    this.gradient,
    this.glowColor,
    this.foregroundColor,
    this.size = 56,
    this.heroTag,
    this.semanticLabel,
  });

  /// Explicit constructor for extended mode.
  const LumenFab.extended({
    required this.icon,
    required this.onPressed,
    required String this.label,
    super.key,
    this.busy = false,
    this.gradient,
    this.glowColor,
    this.foregroundColor,
    this.heroTag,
  }) : size = 56,
       semanticLabel = null;

  /// Icon displayed on the button.
  final IconData icon;

  /// Callback executed when touching the FAB.
  /// When `null`, the FAB is visually disabled.
  final VoidCallback? onPressed;

  /// If entered, it becomes extended FAB (icon + text).
  final String? label;

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

  /// Diameter in compact mode.
  ///
  /// In extended mode it only defines the height.
  final double size;

  /// Tag for Hero animation.
  ///
  /// Passed on to internal [Material] via [Hero].
  final Object? heroTag;

  /// Label for screen readers in compact mode (icon only).
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final LumenPalette palette = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final bool enabled = onPressed != null && !busy;
    final Gradient g = gradient ?? palette.accentGradient;
    final Color glow = glowColor ?? palette.secondary;
    final Color fg = foregroundColor ?? palette.backgroundDeep;
    final extended = label != null;

    final BorderRadius radius = style.radius(size / 2);

    final Widget content = LumenActionContent(
      color: fg,
      label: label,
      icon: icon,
      busy: busy,
      iconSize: 22,
      spinnerSize: 20,
    );

    final Widget body = Container(
      height: size,
      width: extended ? null : size,
      decoration: BoxDecoration(
        gradient: style.fill(g),
        borderRadius: radius,
        boxShadow: style.shadows(
          enabled
              ? <BoxShadow>[
                  BoxShadow(
                    color: glow.withValues(alpha: 0.45),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
      ),
      padding: extended ? const EdgeInsets.symmetric(horizontal: 20) : null,
      alignment: extended ? null : Alignment.center,
      child: content,
    );

    final Widget interactive = LumenPressable(
      onTap: onPressed,
      enabled: !busy,
      borderRadius: radius,
      semanticLabel: label == null ? semanticLabel : null,
      child: body,
    );

    if (heroTag != null) {
      return Hero(tag: heroTag!, child: interactive);
    }
    return interactive;
  }
}
