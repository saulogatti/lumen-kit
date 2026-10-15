import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../foundation/lumen_labeled.dart';
import '../foundation/lumen_pressable.dart';
import '../foundation/lumen_tokens.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Square checkbox with an accent border and gradient marker when active.
class LumenCheckbox extends StatelessWidget {
  /// Creates a neon checkbox.
  const LumenCheckbox({
    required this.value,
    required this.onChanged,
    super.key,
    this.accentColor,
    this.label,
    this.tristate = false,
  });

  /// Current checkbox value.
  ///
  /// When [tristate] is `true`, `null` represents the indeterminate state.
  final bool? value;

  /// Callback called with the next value when the checkbox is tapped.
  ///
  /// When `null`, the checkbox appears disabled.
  final ValueChanged<bool?>? onChanged;

  /// Accent color override. Default: `palette.primary`.
  final Color? accentColor;

  /// Optional text displayed next to the checkbox.
  final String? label;

  /// If `true`, cycles between `false`, `true`, and `null`.
  final bool tristate;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final Color accent = accentColor ?? p.primary;
    final disabled = onChanged == null;
    final isChecked = value == true;
    final bool isIndeterminate = value == null && tristate;

    // false → true → null (tristate) → false.
    void toggle() => onChanged!(switch (value) {
      false => true,
      true => tristate ? null : false,
      null => false,
    });

    final Widget box = AnimatedContainer(
      duration: LumenMotion.duration(context, kLumenFastDuration),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        borderRadius: style.radius(6),
        gradient: style.fill(
          isChecked || isIndeterminate
              ? LumenDecorations.accent(p, accent)
              : null,
        ),
        color: (isChecked || isIndeterminate)
            ? null
            : p.surface.withValues(alpha: style.surfaceAlpha(0.7)),
        border: style.borderAll(
          color: (isChecked || isIndeterminate)
              ? accent
              : p.surfaceOutline.outlineAlpha(0.9),
          width: 1.2,
        ),
        boxShadow: style.shadows(
          (isChecked || isIndeterminate)
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
      child: isIndeterminate
          ? Center(child: Container(width: 10, height: 2, color: p.textPrimary))
          : isChecked
          ? Icon(Icons.check_rounded, size: 16, color: p.textPrimary)
          : null,
    );

    return LumenPressable(
      onTap: disabled ? null : toggle,
      borderRadius: style.radius(6),
      checked: isChecked,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: LumenLabeled(control: box, label: label, enabled: !disabled),
      ),
    );
  }
}
