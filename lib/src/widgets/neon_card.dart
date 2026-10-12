import 'package:material_ui/material_ui.dart';

import '../foundation/neon_decorations.dart';
import '../foundation/neon_pressable.dart';
import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Container base do tema neon: gradiente sutil + borda accent + opcional onTap.
/// Use como peça fundamental para qualquer tela — cards, painéis, seções.
class NeonCard extends StatelessWidget {

  /// Cria um card neon com [child] como conteúdo.
  const NeonCard({
    required this.child,
    super.key,
    this.accent,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.onTap,
    this.borderOpacity = 0.35,
    this.glow = false,
  });
  /// Conteúdo exibido dentro do card.
  final Widget child;

  /// Cor de destaque (borda + glow). Default: `palette.primary`.
  final Color? accent;

  /// Espaçamento interno aplicado ao [child].
  final EdgeInsetsGeometry padding;

  /// Raio dos cantos do card em pixels lógicos.
  final double borderRadius;

  /// Callback executado ao tocar no card.
  ///
  /// Quando `null`, o card é renderizado sem comportamento interativo.
  final VoidCallback? onTap;

  /// Opacidade da borda de destaque.
  final double borderOpacity;

  /// Se `true`, adiciona um leve glow ao redor do card.
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Color a = accent ?? p.primary;
    final BorderRadius radius = style.radius(borderRadius);

    final Widget content = style.frost(
      borderRadius: radius,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: style.fill(
            NeonDecorations.diagonal(
              p.surface.withValues(alpha: style.surfaceAlpha(0.95)),
              p.backgroundMid.withValues(alpha: style.surfaceAlpha(0.85)),
            ),
          ),
          border: style.borderAll(
            color: a.withValues(alpha: borderOpacity),
            width: 1.2,
          ),
        ),
        child: child,
      ),
    );

    final Widget body = onTap == null
        ? content
        : NeonPressable(
            onTap: onTap,
            borderRadius: radius,
            mergeSemantics: false,
            child: content,
          );

    if (!glow) return body;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: style.shadows(<BoxShadow>[
          BoxShadow(
            color: a.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ]),
      ),
      child: body,
    );
  }
}
