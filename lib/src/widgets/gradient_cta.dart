import 'package:material_ui/material_ui.dart';

import '../foundation/neon_action_content.dart';
import '../foundation/neon_pressable.dart';
import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// CTA primário com gradiente neon. Reutilizado em todas as telas.
class GradientCta extends StatelessWidget {
  /// Cria um CTA primário com gradiente.
  const GradientCta({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.busy = false,
    this.gradient,
    this.glowColor,
    this.foregroundColor,
    this.borderRadius = 14,
  });

  /// Texto exibido no CTA.
  final String label;

  /// Callback executado ao tocar no CTA.
  ///
  /// Quando `null`, o CTA fica visualmente desabilitado.
  final VoidCallback? onPressed;

  /// Ícone opcional exibido antes de [label].
  final IconData? icon;

  /// Se `true`, exibe indicador de progresso e bloqueia o toque.
  final bool busy;

  /// Gradiente do botão. Default: `palette.accentGradient`.
  final Gradient? gradient;

  /// Cor do glow (boxShadow). Default: `palette.secondary`.
  final Color? glowColor;

  /// Cor do texto/ícone. Default: `palette.backgroundDeep`.
  final Color? foregroundColor;

  /// Raio dos cantos do botão em pixels lógicos.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final bool enabled = onPressed != null && !busy;
    final Gradient g = gradient ?? p.accentGradient;
    final Color glow = glowColor ?? p.secondary;
    final Color fg = foregroundColor ?? p.backgroundDeep;

    return NeonPressable(
      onTap: onPressed,
      enabled: !busy,
      borderRadius: style.radius(borderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          gradient: style.fill(g),
          borderRadius: style.radius(borderRadius),
          boxShadow: style.shadows(
            enabled
                ? <BoxShadow>[
                    BoxShadow(
                      color: glow.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
        ),
        child: NeonActionContent(
          color: fg,
          label: label,
          icon: icon,
          busy: busy,
        ),
      ),
    );
  }
}
