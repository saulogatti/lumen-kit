import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../foundation/lumen_labeled.dart';
import '../foundation/lumen_pressable.dart';
import '../foundation/lumen_tokens.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Checkbox quadrado com borda accent e marcador em gradiente quando ativo.
class LumenCheckbox extends StatelessWidget {
  /// Cria um checkbox neon.
  const LumenCheckbox({
    required this.value,
    required this.onChanged,
    super.key,
    this.accentColor,
    this.label,
    this.tristate = false,
  });

  /// Valor atual do checkbox.
  ///
  /// Quando [tristate] é `true`, `null` representa o estado indeterminado.
  final bool? value;

  /// Callback chamado com o próximo valor ao tocar no checkbox.
  ///
  /// Quando `null`, o checkbox fica visualmente desabilitado.
  final ValueChanged<bool?>? onChanged;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  /// Texto opcional exibido ao lado do checkbox.
  final String? label;

  /// Se `true`, alterna entre `false`, `true` e `null`.
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
              : p.surfaceOutline.withValues(alpha: 0.9),
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
