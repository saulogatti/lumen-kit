import 'package:material_ui/material_ui.dart';

/// Conteúdo padrão de ação: spinner (quando [busy]) ou [icon], seguido do
/// [label]. Compartilhado por botões, CTA e FAB.
class NeonActionContent extends StatelessWidget {
  /// Cria o conteúdo de uma ação.
  const NeonActionContent({
    required this.color,
    super.key,
    this.label,
    this.icon,
    this.busy = false,
    this.iconSize = 18,
    this.spinnerSize = 16,
    this.gap = 10,
    this.expand = false,
    this.textStyle,
  });

  /// Cor do texto, ícone e spinner.
  final Color color;

  /// Texto. Se `null`, mostra só o ícone/spinner.
  final String? label;

  /// Ícone exibido antes do [label].
  final IconData? icon;

  /// Troca o ícone por um spinner.
  final bool busy;

  /// Tamanho do ícone.
  final double iconSize;

  /// Lado do spinner.
  final double spinnerSize;

  /// Espaço entre ícone e texto.
  final double gap;

  /// Ocupa toda a largura, centralizando o conteúdo.
  final bool expand;

  /// Estilo do texto. Default: `labelLarge` do tema.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final Widget? leading = busy
        ? SizedBox.square(
            dimension: spinnerSize,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          )
        : icon == null
        ? null
        : Icon(icon, color: color, size: iconSize);

    if (label == null) return leading ?? const SizedBox.shrink();

    return Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: gap,
      children: <Widget>[
        ?leading,
        Text(
          label!,
          style: (textStyle ?? Theme.of(context).textTheme.labelLarge)
              ?.copyWith(color: color),
        ),
      ],
    );
  }
}
