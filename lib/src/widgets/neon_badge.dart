import 'package:material_ui/material_ui.dart';

import '../foundation/neon_pressable.dart';
import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Pequeno selo (geralmente para contadores) que pode ficar livre ou
/// ancorado em [child] no canto superior direito.
class NeonBadge extends StatelessWidget {
  /// Cria um badge com texto ou ancorado em [child].
  const NeonBadge({
    required this.label,
    super.key,
    this.color,
    this.child,
    this.dot = false,
    this.dense = false,
  });

  /// Modo "ponto" (sem texto), útil para indicar atividade.
  const NeonBadge.dot({super.key, this.color, this.child})
    : label = '',
      dot = true,
      dense = false;

  /// Texto exibido dentro do badge quando [dot] é `false`.
  final String label;

  /// Cor de fundo do badge. Default: `palette.danger`.
  final Color? color;

  /// Widget opcional usado como âncora para posicionar o badge.
  final Widget? child;

  /// Se `true`, renderiza apenas um ponto sem [label].
  final bool dot;

  /// Versão menor, para ícones de navegação.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Color c = color ?? p.danger;

    // Texto legível sobre qualquer cor de fundo, não só sobre vermelho.
    final Color fg = ThemeData.estimateBrightnessForColor(c) == Brightness.dark
        ? Colors.white
        : Colors.black;

    final Widget badge = Container(
      padding: switch ((dot, dense)) {
        (true, _) => EdgeInsets.zero,
        (false, true) => const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        (false, false) => const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 2,
        ),
      },
      constraints: switch ((dot, dense)) {
        (true, _) => const BoxConstraints(minWidth: 10, minHeight: 10),
        (false, true) => null,
        (false, false) => const BoxConstraints(minWidth: 18, minHeight: 18),
      },
      decoration: BoxDecoration(
        color: c,
        borderRadius: style.radius(dot ? 10 : (dense ? 8 : 12)),
        boxShadow: style.shadows(<BoxShadow>[
          BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: dense ? 6 : 8),
        ]),
      ),
      alignment: dense ? null : Alignment.center,
      child: dot
          ? null
          : Text(
              label,
              style: TextStyle(
                fontSize: dense ? 9 : 10,
                fontWeight: FontWeight.w700,
                color: fg,
                height: dense ? null : 1,
              ),
            ),
    );

    if (child == null) return badge;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        child!,
        Positioned(right: -4, top: -4, child: badge),
      ],
    );
  }
}

/// Tag compacta — variação leve do `StatusChip`, sem ícone obrigatório e sem
/// glow forte. Boa para metadados em listas.
class NeonTag extends StatelessWidget {
  /// Cria uma tag compacta para metadados ou filtros.
  const NeonTag({
    required this.label,
    super.key,
    this.color,
    this.icon,
    this.onTap,
  });

  /// Texto exibido na tag.
  final String label;

  /// Cor de destaque da tag. Default: `palette.primary`.
  final Color? color;

  /// Ícone opcional exibido antes de [label].
  final IconData? icon;

  /// Callback executado ao tocar na tag.
  ///
  /// Quando `null`, a tag é renderizada sem comportamento interativo.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Color c = color ?? p.primary;

    final Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: style.radius(20),
        border: style.borderAll(color: c.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: <Widget>[
          if (icon != null) Icon(icon, size: 12, color: c),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return NeonPressable(
      onTap: onTap,
      borderRadius: style.radius(20),
      child: content,
    );
  }
}
