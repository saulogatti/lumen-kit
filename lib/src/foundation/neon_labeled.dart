import 'package:material_ui/material_ui.dart';

import '../theme/neon_palette.dart';

/// Controle seguido de um rótulo de texto, com a cor apagada quando
/// desabilitado. Base de checkbox, radio e switch com `label`.
class NeonLabeled extends StatelessWidget {
  /// Cria um controle rotulado. Sem [label], devolve só o [control].
  const NeonLabeled({
    required this.control,
    super.key,
    this.label,
    this.enabled = true,
    this.gap = 10,
  });

  /// O controle (caixa, círculo, trilho…).
  final Widget control;

  /// Texto ao lado do controle.
  final String? label;

  /// Se `false`, o texto usa `palette.textMuted`.
  final bool enabled;

  /// Espaço entre controle e texto.
  final double gap;

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return control;
    }
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final Widget text = Text(
      label!,
      style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: enabled ? p.textPrimary : p.textMuted),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: gap,
      children: <Widget>[
        control,
        Flexible(child: text),
      ],
    );
  }
}
