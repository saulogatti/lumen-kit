import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../foundation/lumen_labeled.dart';
import '../foundation/lumen_pressable.dart';
import '../foundation/lumen_tokens.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Radio circular com glow no estado selecionado. Genérico em [T] para casar
/// com o `groupValue` do chamador.
class LumenRadio<T> extends StatelessWidget {
  /// Cria uma opção de radio para valores do tipo [T].
  const LumenRadio({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.key,
    this.accentColor,
    this.label,
  });

  /// Valor representado por esta opção.
  final T value;

  /// Valor atualmente selecionado no grupo.
  ///
  /// A opção fica selecionada quando [value] é igual a [groupValue].
  final T? groupValue;

  /// Callback chamado com [value] ao tocar nesta opção.
  ///
  /// Quando `null`, o radio fica visualmente desabilitado.
  final ValueChanged<T?>? onChanged;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  /// Texto opcional exibido ao lado do radio.
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
          color: selected ? accent : p.surfaceOutline.withValues(alpha: 0.9),
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
