import 'package:lumen_kit/src/foundation/lumen_decorations.dart';
import 'package:lumen_kit/src/foundation/lumen_labeled.dart';
import 'package:lumen_kit/src/foundation/lumen_pressable.dart';
import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Circular radio with glow in the selected state.
///
/// Generic in [T] to get married with the caller's `groupValue`.
class LumenRadio<T> extends StatelessWidget {
  /// Creates a radio option for values ​​of type [T].
  const LumenRadio({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.key,
    this.accentColor,
    this.label,
  });

  /// Value represented by this option.
  final T value;

  /// Value currently selected in the group.
  /// The option is selected when [value] is equal to [groupValue].
  final T? groupValue;

  /// Callback called with [value] when touching this option.
  /// When `null`, the radio is visually disabled.
  final ValueChanged<T?>? onChanged;

  /// Highlight color override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Optional text displayed next to the radio.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final accent = accentColor ?? p.primary;
    final disabled = onChanged == null;
    final selected = value == groupValue;

    final Widget circle = AnimatedContainer(
      duration: LumenMotion.duration(context, kLumenFastDuration),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: p.surface.withValues(alpha: style.surfaceAlpha(0.7)),
        border: style.borderAll(
          color: selected ? accent : p.surfaceOutline.outlineAlpha(0.9),
          width: 1.4,
        ),
        boxShadow: style.shadows(
          selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: accent.withValues(alpha: 0.45),
                    blurRadius: 10,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
      ),
      child: Center(
        child: AnimatedContainer(
          duration: LumenMotion.duration(context, kLumenFastDuration),
          width: selected ? 12 : 0,
          height: selected ? 12 : 0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: style.fill(LumenDecorations.accent(p, accent)),
          ),
        ),
      ),
    );

    return LumenPressable(
      onTap: disabled ? null : () => onChanged!(value),
      borderRadius: style.radius(20),
      checked: selected,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: LumenLabeled(control: circle, label: label, enabled: !disabled),
      ),
    );
  }
}
