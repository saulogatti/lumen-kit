import 'package:material_ui/material_ui.dart';

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
  });

  /// Modo "ponto" (sem texto), útil para indicar atividade.
  const NeonBadge.dot({super.key, this.color, this.child})
    : label = '',
      dot = true;

  /// Texto exibido dentro do badge quando [dot] é `false`.
  final String label;

  /// Cor de fundo do badge. Default: `palette.danger`.
  final Color? color;

  /// Widget opcional usado como âncora para posicionar o badge.
  final Widget? child;

  /// Se `true`, renderiza apenas um ponto sem [label].
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Color c = color ?? p.danger;

    final Widget badge = Container(
      padding: dot
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      constraints: dot
          ? const BoxConstraints(minWidth: 10, minHeight: 10)
          : const BoxConstraints(minWidth: 18, minHeight: 18),
      decoration: BoxDecoration(
        color: c,
        borderRadius: style.radius(dot ? 10 : 12),
        boxShadow: style.shadows(<BoxShadow>[
          BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: 8),
        ]),
      ),
      alignment: Alignment.center,
      child: dot
          ? null
          : Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1,
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
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 12, color: c),
            const SizedBox(width: 4),
          ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: style.radius(20),
      child: content,
    );
  }
}
