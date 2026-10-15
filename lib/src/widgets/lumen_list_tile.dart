import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_pressable.dart';
import '../foundation/lumen_tokens.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Themed ListTile with a translucent surface, subtle accent border, and
/// selected state highlighted with a glow.
class LumenListTile extends StatelessWidget {
  /// Creates a neon list item.
  const LumenListTile({
    required this.title,
    super.key,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.accentColor,
    this.dense = false,
  });

  /// Main item text.
  final String title;

  /// Supporting text displayed below [title].
  final String? subtitle;

  /// Optional widget displayed before the text.
  final Widget? leading;

  /// Optional widget displayed at the end of the row.
  final Widget? trailing;

  /// Callback run when the item is tapped.
  final VoidCallback? onTap;

  /// Callback run on long press.
  final VoidCallback? onLongPress;

  /// If `true`, applies visual selection highlighting.
  final bool selected;

  /// Accent color override. Default: `palette.primary`.
  final Color? accentColor;

  /// If `true`, reduces vertical spacing.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final Color accent = accentColor ?? p.primary;
    final bool disabled = onTap == null && onLongPress == null;

    // A tile without an action is informational: dim it less than a disabled
    // control (0.7 instead of kLumenDisabledOpacity).
    return Opacity(
      opacity: disabled && !selected ? 0.7 : 1,
      child: LumenPressable(
        onTap: onTap,
        onLongPress: onLongPress,
        selected: selected,
        button: !disabled,
        dimWhenDisabled: false,
        borderRadius: style.radius(14),
        child: AnimatedContainer(
          duration: LumenMotion.duration(context, kLumenFastDuration),
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: dense ? 8 : 12,
          ),
          decoration: BoxDecoration(
            borderRadius: style.radius(14),
            color: selected
                ? accent.withValues(alpha: 0.14)
                : p.surface.withValues(alpha: style.surfaceAlpha(0.5)),
            border: style.borderAll(
              color: selected
                  ? accent.withValues(alpha: 0.6)
                  : p.surfaceOutline.outlineAlpha(0.45),
            ),
            boxShadow: style.shadows(
              selected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: accent.withValues(alpha: 0.28),
                        blurRadius: 14,
                        spreadRadius: -3,
                      ),
                    ]
                  : null,
            ),
          ),
          child: Row(
            children: <Widget>[
              if (leading case final Widget leading) ...<Widget>[
                leading,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: p.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle case final String subtitle) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: p.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing case final Widget trailing) ...<Widget>[
                const SizedBox(width: 8),
                trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
