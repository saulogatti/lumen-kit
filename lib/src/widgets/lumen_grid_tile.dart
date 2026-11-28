import 'package:lumen_kit/src/foundation/lumen_pressable.dart';
import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Vertical counterpart of `LumenListTile`: [leading] on top, [title] and
/// [subtitle] below, on the same translucent surface with a glow when
/// [selected].
///
/// Made for the cells of a `LumenGrid`, where it fills the cell. Long texts
/// are cut with an ellipsis instead of overflowing.
///
/// ```dart
/// LumenGridTile(
///   title: 'Orders',
///   subtitle: '12 open',
///   leading: const Icon(Icons.receipt_long_outlined),
///   selected: current == Module.orders,
///   onTap: () => open(Module.orders),
/// )
/// ```
class LumenGridTile extends StatelessWidget {
  /// Main text of the cell.
  final String title;

  /// Auxiliary text displayed below [title].
  final String? subtitle;

  /// Optional widget displayed above the texts, usually an icon or avatar.
  ///
  /// Icons take the highlight color.
  final Widget? leading;

  /// Callback executed when touching the cell.
  final VoidCallback? onTap;

  /// Callback executed on long press.
  final VoidCallback? onLongPress;

  /// Whether to apply visual selection highlighting.
  final bool selected;

  /// Highlight color override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Space between the surface border and the content.
  final EdgeInsetsGeometry padding;

  /// Horizontal placement of [leading] and the texts.
  ///
  /// [CrossAxisAlignment.center] centers the text; the other values align it
  /// to the start or the end.
  final CrossAxisAlignment crossAxisAlignment;

  /// Largest number of lines of [title] before the ellipsis.
  final int titleMaxLines;

  /// Largest number of lines of [subtitle] before the ellipsis.
  final int subtitleMaxLines;

  /// Creates a vertical tile for grids.
  const LumenGridTile({
    required this.title,
    super.key,
    this.subtitle,
    this.leading,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.accentColor,
    this.padding = const EdgeInsets.all(14),
    this.crossAxisAlignment = .center,
    this.titleMaxLines = 2,
    this.subtitleMaxLines = 2,
  }) : assert(titleMaxLines > 0, 'titleMaxLines must be greater than zero.'),
       assert(subtitleMaxLines > 0, 'subtitleMaxLines must be greater than zero.');

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final text = Theme.of(context).textTheme;
    final accent = accentColor ?? p.primary;
    final disabled = onTap == null && onLongPress == null;
    final textAlign = switch (crossAxisAlignment) {
      .end => TextAlign.end,
      .center => TextAlign.center,
      _ => TextAlign.start,
    };

    // A tile without an action is informational: dim it less than a disabled
    // control (0.7 instead of kLumenDisabledOpacity), as LumenListTile does.
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
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: style.radius(14),
            color: selected
                ? accent.withValues(alpha: 0.14)
                : p.surface.withValues(alpha: style.surfaceAlpha(0.5)),
            border: style.borderAll(
              color: selected ? accent.withValues(alpha: 0.6) : p.surfaceOutline.outlineAlpha(0.45),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: crossAxisAlignment,
            children: <Widget>[
              if (leading case final Widget leading) ...<Widget>[
                IconTheme.merge(
                  data: IconThemeData(color: accent, size: 28),
                  child: leading,
                ),
                const SizedBox(height: 10),
              ],
              Flexible(
                child: Text(
                  title,
                  maxLines: titleMaxLines,
                  overflow: TextOverflow.ellipsis,
                  textAlign: textAlign,
                  style: text.titleSmall?.copyWith(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (subtitle case final String subtitle) ...<Widget>[
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    subtitle,
                    maxLines: subtitleMaxLines,
                    overflow: TextOverflow.ellipsis,
                    textAlign: textAlign,
                    style: text.bodySmall?.copyWith(color: p.textMuted),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
