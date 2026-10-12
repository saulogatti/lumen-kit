import 'package:material_ui/material_ui.dart';

import '../theme/neon_palette.dart';

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
    final Color accent = accentColor ?? p.primary;
    final bool disabled = onChanged == null;
    final bool selected = value == groupValue;

    final Widget circle = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: p.surface.withValues(alpha: 0.7),
        border: Border.all(
          color: selected ? accent : p.surfaceOutline.withValues(alpha: 0.9),
          width: 1.4,
        ),
        boxShadow: selected
            ? <BoxShadow>[
                BoxShadow(
                  color: accent.withValues(alpha: 0.45),
                  blurRadius: 10,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: selected ? 12 : 0,
          height: selected ? 12 : 0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: <Color>[accent, p.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );

    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: InkWell(
        onTap: disabled ? null : () => onChanged!(value),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: label == null
              ? circle
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    circle,
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        label!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: disabled ? p.textMuted : p.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
