import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_action_content.dart';
import '../foundation/lumen_pressable.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Visual variants of [LumenIconButton].
enum LumenIconButtonVariant {
  /// Filled with a neon gradient.
  solid,

  /// Neon border with translucent background.
  outline,

  /// Accent-colored icon only, without a background or border.
  ghost,
}

/// Circular/square button containing only an icon, in the neon style.
class LumenIconButton extends StatelessWidget {
  /// Creates an icon button using the [variant].
  const LumenIconButton({
    required this.icon,
    required this.onPressed,
    super.key,
    this.variant = LumenIconButtonVariant.outline,
    this.tooltip,
    this.busy = false,
    this.accentColor,
    this.size = 44,
    this.iconSize = 20,
    this.shape = LumenIconButtonShape.circle,
    this.semanticLabel,
  });

  /// Shortcut for [LumenIconButtonVariant.solid].
  const LumenIconButton.solid({
    required this.icon,
    required this.onPressed,
    super.key,
    this.tooltip,
    this.busy = false,
    this.accentColor,
    this.size = 44,
    this.iconSize = 20,
    this.shape = LumenIconButtonShape.circle,
    this.semanticLabel,
  }) : variant = LumenIconButtonVariant.solid;

  /// Shortcut for [LumenIconButtonVariant.ghost].
  const LumenIconButton.ghost({
    required this.icon,
    required this.onPressed,
    super.key,
    this.tooltip,
    this.busy = false,
    this.accentColor,
    this.size = 44,
    this.iconSize = 20,
    this.shape = LumenIconButtonShape.circle,
    this.semanticLabel,
  }) : variant = LumenIconButtonVariant.ghost;

  /// Icon displayed on the button.
  final IconData icon;

  /// Callback run when the button is tapped.
  ///
  /// When `null`, the button appears disabled.
  final VoidCallback? onPressed;

  /// Visual variant applied to the button.
  final LumenIconButtonVariant variant;

  /// Optional message displayed in a [Tooltip].
  final String? tooltip;

  /// If `true`, displays a progress indicator and blocks taps.
  final bool busy;

  /// Accent override. Default: `palette.primary`.
  final Color? accentColor;

  /// Total area size (width = height).
  final double size;

  /// Icon or progress indicator size.
  final double iconSize;

  /// Button shape: circle or rounded square.
  final LumenIconButtonShape shape;

  /// Label for screen readers when there is no [tooltip].
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final LumenPalette palette = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final bool enabled = onPressed != null && !busy;
    final Color accent = accentColor ?? palette.primary;

    final BorderRadius radius = switch (shape) {
      LumenIconButtonShape.circle => style.radius(size / 2),
      LumenIconButtonShape.rounded => style.radius(12),
    };

    final Color fg = variant == LumenIconButtonVariant.solid
        ? palette.backgroundDeep
        : accent;

    final Widget content = Center(
      child: LumenActionContent(
        color: fg,
        icon: icon,
        busy: busy,
        iconSize: iconSize,
        spinnerSize: iconSize,
      ),
    );

    final Widget body = switch (variant) {
      LumenIconButtonVariant.solid => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: style.fill(palette.accentGradient),
          borderRadius: radius,
          boxShadow: style.shadows(
            enabled
                ? <BoxShadow>[
                    BoxShadow(
                      color: (accentColor ?? palette.secondary).withValues(
                        alpha: 0.35,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
        ),
        child: content,
      ),
      LumenIconButtonVariant.outline => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: palette.surface.withValues(alpha: style.surfaceAlpha(0.35)),
          borderRadius: radius,
          border: style.borderAll(
            color: accent.withValues(alpha: 0.85),
            width: 1.2,
          ),
          boxShadow: style.shadows(
            enabled
                ? <BoxShadow>[
                    BoxShadow(
                      color: accent.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
        ),
        child: content,
      ),
      LumenIconButtonVariant.ghost => SizedBox(
        width: size,
        height: size,
        child: content,
      ),
    };

    final Widget interactive = LumenPressable(
      onTap: onPressed,
      enabled: !busy,
      borderRadius: radius,
      // The Tooltip already announces the message when present.
      semanticLabel: tooltip == null ? semanticLabel : null,
      child: body,
    );

    return tooltip == null
        ? interactive
        : Tooltip(message: tooltip, child: interactive);
  }
}

/// Shape of [LumenIconButton].
enum LumenIconButtonShape {
  /// Circular button.
  circle,

  /// Square button with rounded corners.
  rounded,
}
