import 'package:lumen_kit/src/foundation/lumen_action_content.dart';
import 'package:lumen_kit/src/foundation/lumen_pressable.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Visual variants of [LumenButton].
enum LumenButtonVariant {
  /// Filled with neon gradient.
  ///
  /// Equivalent to the primary CTA.
  solid,

  /// Neon border with translucent background.
  ///
  /// Secondary action.
  outline,

  /// No border or background — just text/icon with accent color.
  ///
  /// Tertiary action.
  ghost,
}

/// Neon button with three variants: [LumenButtonVariant.solid],
/// [LumenButtonVariant.outline] and [LumenButtonVariant.ghost].
/// For primary CTA with full gradient, prefer [LumenButtonVariant.solid] (or
/// the historical shortcut `LumenCta`).
class LumenButton extends StatelessWidget {
  /// Creates a neon button on the informed [variant].
  const LumenButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = LumenButtonVariant.solid,
    this.icon,
    this.busy = false,
    this.accentColor,
    this.borderRadius = 14,
    this.expand = false,
  });

  /// Shortcut for [LumenButtonVariant.outline].
  const LumenButton.outline({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.busy = false,
    this.accentColor,
    this.borderRadius = 14,
    this.expand = false,
  }) : variant = LumenButtonVariant.outline;

  /// Shortcut for [LumenButtonVariant.ghost].
  const LumenButton.ghost({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.busy = false,
    this.accentColor,
    this.borderRadius = 14,
    this.expand = false,
  }) : variant = LumenButtonVariant.ghost;

  /// Text displayed on the button.
  final String label;

  /// Callback executed when touching the button.
  /// When `null`, the button is visually disabled.
  final VoidCallback? onPressed;

  /// Visual variant applied to the button.
  final LumenButtonVariant variant;

  /// Optional icon displayed before [label].
  final IconData? icon;

  /// Whether to display progress indicator and blocks ringing.
  final bool busy;

  /// Accent override.
  ///
  /// Default: `palette.primary` for outline/ghost, `palette.accentGradient` for
  /// solid.
  final Color? accentColor;

  /// Radius of button corners in logical pixels.
  final double borderRadius;

  /// If `true`, it occupies the entire available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final palette = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final enabled = onPressed != null && !busy;
    final accent = accentColor ?? palette.primary;

    final content = _buildContent(palette, accent);

    final body = switch (variant) {
      LumenButtonVariant.solid => _solid(context, palette, content, enabled),
      LumenButtonVariant.outline => _outline(
        context,
        palette,
        accent,
        content,
        enabled,
      ),
      LumenButtonVariant.ghost => _ghost(content),
    };

    return LumenPressable(
      onTap: onPressed,
      enabled: !busy,
      borderRadius: style.radius(borderRadius),
      child: body,
    );
  }

  Widget _buildContent(LumenPalette palette, Color accent) {
    final fg = switch (variant) {
      LumenButtonVariant.solid => palette.backgroundDeep,
      LumenButtonVariant.outline || LumenButtonVariant.ghost => accent,
    };

    return LumenActionContent(
      color: fg,
      label: label,
      icon: icon,
      busy: busy,
      expand: expand,
    );
  }

  Widget _solid(
    BuildContext context,
    LumenPalette palette,
    Widget content,
    bool enabled,
  ) {
    final style = LumenStyle.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        gradient: style.fill(palette.accentGradient),
        borderRadius: style.radius(borderRadius),
        boxShadow: style.shadows(
          enabled
              ? <BoxShadow>[
                  BoxShadow(
                    color: (accentColor ?? palette.secondary).withValues(
                      alpha: 0.35,
                    ),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
      ),
      child: content,
    );
  }

  Widget _outline(
    BuildContext context,
    LumenPalette palette,
    Color accent,
    Widget content,
    bool enabled,
  ) {
    final style = LumenStyle.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: style.surfaceAlpha(0.35)),
        borderRadius: style.radius(borderRadius),
        border: style.borderAll(
          color: accent.withValues(alpha: 0.85),
          width: 1.2,
        ),
        boxShadow: style.shadows(
          enabled
              ? <BoxShadow>[
                  BoxShadow(
                    color: accent.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
      ),
      child: content,
    );
  }

  Widget _ghost(Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: content,
    );
  }
}
