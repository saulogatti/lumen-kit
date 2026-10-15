import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../foundation/lumen_labeled.dart';
import '../foundation/lumen_pressable.dart';
import '../foundation/lumen_tokens.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Circular radio with a glow in the selected state. Generic in [T] to match
/// the caller's `groupValue`.
class LumenRadio<T> extends StatelessWidget {
  /// Creates a radio option for values of type [T].
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

  /// Currently selected group value.
  ///
  /// The option is selected when [value] equals [groupValue].
  final T? groupValue;

  /// Callback called with [value] when this option is tapped.
  ///
  /// When `null`, the radio appears disabled.
  final ValueChanged<T?>? onChanged;

  /// Accent color override. Default: `palette.primary`.
  final Color? accentColor;

  /// Optional text displayed next to the radio.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final Color accent = accentColor ?? p.primary;
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
