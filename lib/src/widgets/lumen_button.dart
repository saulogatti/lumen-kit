import 'package:lumen_kit/src/foundation/lumen_action_content.dart';
import 'package:lumen_kit/src/foundation/lumen_pressable.dart';
import 'package:lumen_kit/src/theme/lumen_contrast.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:lumen_kit/src/widgets/lumen_status_chip.dart';
import 'package:material_ui/material_ui.dart';

/// Visual variants of [LumenButton].
enum LumenButtonVariant {
  /// Filled with neon gradient, or with the color of [LumenButton.tone].
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
///
/// Set [tone] to give the button a semantic color. A solid button with a tone
/// fills with that color instead of the accent gradient, so a destructive
/// confirmation reads as one:
///
/// ```dart
/// LumenButton.danger(label: 'Delete', icon: Icons.delete_outline, onPressed: onDelete);
/// LumenButton.outline(label: 'Retry', tone: LumenStatusTone.warning, onPressed: onRetry);
/// ```
class LumenButton extends StatelessWidget {
  /// Creates a neon button on the informed [variant].
  ///
  /// [label] is the button text, and [icon] is an optional leading icon.
  /// A null [onPressed] disables the button; [busy] defaults to false and,
  /// when true, shows a progress indicator and disables interaction.
  ///
  /// [variant] defaults to [LumenButtonVariant.solid]. [tone] optionally
  /// selects a semantic palette color. [accentColor] overrides the outline
  /// or ghost color, or the solid shadow, but not the solid fill. Without an
  /// override these use the tone color, or the palette's primary color
  /// (secondary for the solid shadow) when no tone is set.
  /// [borderRadius] defaults to 14 logical pixels; [expand] defaults to false.
  /// [key] identifies the widget in the tree.
  const LumenButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = LumenButtonVariant.solid,
    this.icon,
    this.busy = false,
    this.accentColor,
    this.tone,
    this.borderRadius = 14,
    this.expand = false,
  });

  /// Shortcut for [LumenButtonVariant.outline].
  ///
  /// [label] is the button text and [icon] is optional. A null [onPressed]
  /// disables the button; [busy] defaults to false and shows a spinner and
  /// disables interaction when true. [tone] supplies a semantic color, and
  /// [accentColor] overrides it, defaulting to the palette's primary color
  /// when neither is set. [borderRadius] defaults to 14 logical pixels;
  /// [expand] defaults to false. [key] identifies the widget in the tree.
  const LumenButton.outline({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.busy = false,
    this.accentColor,
    this.tone,
    this.borderRadius = 14,
    this.expand = false,
  }) : variant = LumenButtonVariant.outline;

  /// Shortcut for [LumenButtonVariant.ghost].
  ///
  /// [label] is the button text and [icon] is optional. A null [onPressed]
  /// disables the button; [busy] defaults to false and shows a spinner and
  /// disables interaction when true. [tone] supplies a semantic color, and
  /// [accentColor] overrides it, defaulting to the palette's primary color
  /// when neither is set. [borderRadius] defaults to 14 logical pixels;
  /// [expand] defaults to false. [key] identifies the widget in the tree.
  const LumenButton.ghost({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.busy = false,
    this.accentColor,
    this.tone,
    this.borderRadius = 14,
    this.expand = false,
  }) : variant = LumenButtonVariant.ghost;

  /// Shortcut for a solid button with [LumenStatusTone.danger].
  ///
  /// Use it for destructive actions, such as the confirm button of a delete
  /// dialog.
  ///
  /// [label] is the button text and [icon] is optional. A null [onPressed]
  /// disables the button; [busy] defaults to false and shows a spinner and
  /// disables interaction when true. [accentColor] overrides the shadow
  /// color, not the danger-colored fill. [borderRadius] defaults to 14
  /// logical pixels; [expand] defaults to false. [key] identifies the widget.
  const LumenButton.danger({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.busy = false,
    this.accentColor,
    this.borderRadius = 14,
    this.expand = false,
  }) : variant = LumenButtonVariant.solid,
       tone = LumenStatusTone.danger;

  /// Text displayed on the button.
  final String label;

  /// Callback executed when touching the button.
  /// When `null`, the button is visually disabled.
  final VoidCallback? onPressed;

  /// Visual variant applied to the button.
  final LumenButtonVariant variant;

  /// Optional icon displayed before [label].
  final IconData? icon;

  /// Whether to show a progress indicator and disable the button.
  final bool busy;

  /// Accent override for the outline, ghost content, or solid shadow.
  ///
  /// Outline and ghost buttons default to the [tone] color, or to the primary
  /// palette color without a tone. Solid buttons default to the [tone] color,
  /// or to the secondary palette color, for the shadow. It never changes the
  /// solid fill; use [tone] for that.
  final Color? accentColor;

  /// Semantic color of the button, resolved from the active palette.
  ///
  /// A solid button fills with a gradient derived from the tone color, which
  /// [LumenStyle.fill] turns into the plain tone color in styles without
  /// gradients. Text and icons use a contrasting color for the styled fill.
  /// Outline and ghost buttons use the tone color for border, text and icon.
  ///
  /// Default: `null`, which keeps the accent gradient and the primary color.
  /// [LumenStatusTone.neutral] uses an opaque [LumenPalette.textMuted].
  final LumenStatusTone? tone;

  /// Radius of button corners in logical pixels.
  final double borderRadius;

  /// If `true`, it occupies the entire available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final palette = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final enabled = onPressed != null && !busy;
    final toneColor = tone?.colorOf(palette).withValues(alpha: 1);
    final accent = accentColor ?? toneColor ?? palette.primary;

    final fill = variant == LumenButtonVariant.solid
        ? style.fill(toneColor == null ? palette.accentGradient : _toneGradient(toneColor))
        : null;
    final fg = fill == null
        ? accent
        : lumenContrastingForeground(fill.colors, backdrop: palette.surface, palette: palette);
    final content = LumenActionContent(
      color: fg,
      label: label,
      icon: icon,
      busy: busy,
      expand: expand,
    );

    final body = switch (variant) {
      LumenButtonVariant.solid => _solid(context, palette, toneColor, fill!, content, enabled),
      LumenButtonVariant.outline => _outline(context, palette, accent, content, enabled),
      LumenButtonVariant.ghost => _ghost(content),
    };

    return LumenPressable(
      onTap: onPressed,
      enabled: !busy,
      borderRadius: style.radius(borderRadius),
      child: body,
    );
  }

  Widget _solid(
    BuildContext context,
    LumenPalette palette,
    Color? toneColor,
    Gradient fill,
    Widget content,
    bool enabled,
  ) {
    final style = LumenStyle.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        gradient: fill,
        borderRadius: style.radius(borderRadius),
        boxShadow: style.shadows(
          enabled
              ? <BoxShadow>[
                  BoxShadow(
                    color: (accentColor ?? toneColor ?? palette.secondary).withValues(alpha: 0.35),
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
        border: style.borderAll(color: accent.withValues(alpha: 0.85), width: 1.2),
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

/// Fill gradient of a solid button with a tone: the tone color fading into a
/// darker shade of itself.
LinearGradient _toneGradient(Color color) {
  final hsl = HSLColor.fromColor(color);
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[color, hsl.withLightness(hsl.lightness * 0.85).toColor()],
  );
}
