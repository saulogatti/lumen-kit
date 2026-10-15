import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../foundation/lumen_labeled.dart';
import '../foundation/lumen_pressable.dart';
import '../foundation/lumen_tokens.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Stylized switch with translucent track, thumb accent and glow when active.
class LumenSwitch extends StatelessWidget {
  /// Creates a neon switch.
  const LumenSwitch({
    required this.value,
    required this.onChanged,
    super.key,
    this.accentColor,
    this.label,
  });

  /// Current switch value.
  final bool value;

  /// Callback called with the value inverted when touching the switch.
  /// When `null`, the switch is visually disabled.
  final ValueChanged<bool>? onChanged;

  /// Highlight color override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Optional text displayed next to the switch.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final Color accent = accentColor ?? p.primary;
    final disabled = onChanged == null;
    final Duration duration = LumenMotion.duration(
      context,
      kLumenMediumDuration,
    );

    final Widget track = AnimatedContainer(
      duration: duration,
      curve: Curves.easeOut,
      width: 52,
      height: 30,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: value
            ? accent.withValues(alpha: 0.25)
            : p.surface.withValues(alpha: style.surfaceAlpha(0.7)),
        borderRadius: style.radius(30),
        border: style.borderAll(
          color: value
              ? accent.withValues(alpha: 0.9)
              : p.surfaceOutline.outlineAlpha(0.8),
          width: 1.2,
        ),
        boxShadow: style.shadows(
          value
              ? <BoxShadow>[
                  BoxShadow(
                    color: accent.withValues(alpha: 0.45),
                    blurRadius: 14,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
      ),
      child: AnimatedAlign(
        duration: duration,
        curve: Curves.easeOut,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: style.fill(
              value ? LumenDecorations.accent(p, accent) : null,
            ),
            color: value ? null : p.textMuted.scaleAlpha(0.85),
            boxShadow: style.shadows(
              value
                  ? <BoxShadow>[
                      BoxShadow(
                        color: accent.withValues(alpha: 0.55),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );

    return LumenPressable(
      onTap: disabled ? null : () => onChanged!(!value),
      borderRadius: style.radius(30),
      toggled: value,
      child: LumenLabeled(
        control: track,
        label: label,
        enabled: !disabled,
        gap: 12,
      ),
    );
  }
}
