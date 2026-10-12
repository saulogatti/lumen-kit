import 'package:material_ui/material_ui.dart';

import '../foundation/neon_action_content.dart';
import '../foundation/neon_pressable.dart';
import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Floating Action Button no estilo neon. Funciona em dois modos:
///
/// - **Compacto** (default, só [icon]) — círculo com gradiente e glow.
/// - **Estendido** (com [label]) — pílula com ícone + texto.
class NeonFab extends StatelessWidget {
  /// Cria um FAB compacto ou estendido quando [label] é informado.
  const NeonFab({
    required this.icon,
    required this.onPressed,
    super.key,
    this.label,
    this.busy = false,
    this.gradient,
    this.glowColor,
    this.foregroundColor,
    this.size = 56,
    this.heroTag,
    this.semanticLabel,
  });

  /// Construtor explícito para o modo estendido.
  const NeonFab.extended({
    required this.icon,
    required this.onPressed,
    required String this.label,
    super.key,
    this.busy = false,
    this.gradient,
    this.glowColor,
    this.foregroundColor,
    this.heroTag,
  }) : size = 56,
       semanticLabel = null;

  /// Ícone exibido no botão.
  final IconData icon;

  /// Callback executado ao tocar no FAB.
  ///
  /// Quando `null`, o FAB fica visualmente desabilitado.
  final VoidCallback? onPressed;

  /// Se informado, vira FAB estendido (ícone + texto).
  final String? label;

  /// Se `true`, exibe indicador de progresso e bloqueia o toque.
  final bool busy;

  /// Gradiente do botão. Default: `palette.accentGradient`.
  final Gradient? gradient;

  /// Cor do glow (boxShadow). Default: `palette.secondary`.
  final Color? glowColor;

  /// Cor do texto/ícone. Default: `palette.backgroundDeep`.
  final Color? foregroundColor;

  /// Diâmetro no modo compacto. No modo estendido define apenas a altura.
  final double size;

  /// Tag para Hero animation. Repassada ao [Material] interno via [Hero].
  final Object? heroTag;

  /// Rótulo para leitores de tela no modo compacto (só ícone).
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final NeonPalette palette = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final bool enabled = onPressed != null && !busy;
    final Gradient g = gradient ?? palette.accentGradient;
    final Color glow = glowColor ?? palette.secondary;
    final Color fg = foregroundColor ?? palette.backgroundDeep;
    final bool extended = label != null;

    final BorderRadius radius = style.radius(size / 2);

    final Widget content = NeonActionContent(
      color: fg,
      label: label,
      icon: icon,
      busy: busy,
      iconSize: 22,
      spinnerSize: 20,
    );

    final Widget body = Container(
      height: size,
      width: extended ? null : size,
      decoration: BoxDecoration(
        gradient: style.fill(g),
        borderRadius: radius,
        boxShadow: style.shadows(
          enabled
              ? <BoxShadow>[
                  BoxShadow(
                    color: glow.withValues(alpha: 0.45),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
      ),
      padding: extended ? const EdgeInsets.symmetric(horizontal: 20) : null,
      alignment: extended ? null : Alignment.center,
      child: content,
    );

    final Widget interactive = NeonPressable(
      onTap: onPressed,
      enabled: !busy,
      borderRadius: radius,
      semanticLabel: label == null ? semanticLabel : null,
      child: body,
    );

    if (heroTag != null) {
      return Hero(tag: heroTag!, child: interactive);
    }
    return interactive;
  }
}
