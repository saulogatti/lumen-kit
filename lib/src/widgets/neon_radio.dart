import 'package:material_ui/material_ui.dart';

import '../foundation/neon_decorations.dart';
import '../foundation/neon_labeled.dart';
import '../foundation/neon_pressable.dart';
import '../foundation/neon_tokens.dart';
import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Radio circular com glow no estado selecionado. Genérico em [T] para casar
/// com o `groupValue` do chamador.
class NeonRadio<T> extends StatelessWidget {
  /// Cria uma opção de radio para valores do tipo [T].
  const NeonRadio({
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
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Color accent = accentColor ?? p.primary;
    final disabled = onChanged == null;
    final selected = value == groupValue;

    final Widget circle = AnimatedContainer(
      duration: NeonMotion.duration(context, kNeonFastDuration),
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
          duration: NeonMotion.duration(context, kNeonFastDuration),
          width: selected ? 12 : 0,
          height: selected ? 12 : 0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: style.fill(NeonDecorations.accent(p, accent)),
          ),
        ),
      ),
    );

    return NeonPressable(
      onTap: disabled ? null : () => onChanged!(value),
      borderRadius: style.radius(20),
      checked: selected,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: NeonLabeled(control: circle, label: label, enabled: !disabled),
      ),
    );
  }
}
