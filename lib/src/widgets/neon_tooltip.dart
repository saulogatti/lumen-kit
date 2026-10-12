import 'package:material_ui/material_ui.dart';

import '../foundation/neon_decorations.dart';
import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Tooltip estilizado seguindo a identidade neon (surface translúcida, borda
/// accent + glow). Wrapper fino sobre o [Tooltip] do Material.
class NeonTooltip extends StatelessWidget {
  /// Cria um tooltip neon para envolver [child].
  const NeonTooltip({
    required this.message,
    required this.child,
    super.key,
    this.accentColor,
    this.waitDuration = const Duration(milliseconds: 300),
    this.showDuration = const Duration(milliseconds: 1800),
    this.preferBelow,
  });

  /// Mensagem exibida pelo tooltip.
  final String message;

  /// Widget que dispara a exibição do tooltip.
  final Widget child;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  /// Tempo de espera antes de exibir o tooltip.
  final Duration waitDuration;

  /// Tempo em que o tooltip permanece visível.
  final Duration showDuration;

  /// Preferência de posicionamento repassada ao [Tooltip].
  final bool? preferBelow;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Color accent = accentColor ?? p.primary;

    return Tooltip(
      message: message,
      waitDuration: waitDuration,
      showDuration: showDuration,
      preferBelow: preferBelow,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      textStyle: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: p.textPrimary),
      decoration: NeonDecorations.panel(
        p,
        style,
        accent: accent,
        radius: 10,
        borderWidth: 1,
        glowBlur: 14,
        glowOffset: const Offset(0, 6),
      ),
      child: child,
    );
  }
}
