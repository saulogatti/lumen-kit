import 'package:material_ui/material_ui.dart';

import '../theme/neon_palette.dart';

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
  }) : size = 56;

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

  /// Cor do glow (boxShadow). Default: `palette.accentMagenta`.
  final Color? glowColor;

  /// Cor do texto/ícone. Default: `palette.backgroundDeep`.
  final Color? foregroundColor;

  /// Diâmetro no modo compacto. No modo estendido define apenas a altura.
  final double size;

  /// Tag para Hero animation. Repassada ao [Material] interno via [Hero].
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final NeonPalette palette = NeonThemeExt.of(context).palette;
    final bool enabled = onPressed != null && !busy;
    final Gradient g = gradient ?? palette.accentGradient;
    final Color glow = glowColor ?? palette.accentMagenta;
    final Color fg = foregroundColor ?? palette.backgroundDeep;
    final bool extended = label != null;

    final BorderRadius radius = BorderRadius.circular(size / 2);

    final Widget iconOrSpinner = busy
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Icon(icon, color: fg, size: 22);

    final Widget content = extended
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                iconOrSpinner,
                const SizedBox(width: 10),
                Text(
                  label!,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: fg),
                ),
              ],
            ),
          )
        : Center(child: iconOrSpinner);

    final Widget body = Container(
      height: size,
      width: extended ? null : size,
      decoration: BoxDecoration(
        gradient: g,
        borderRadius: radius,
        boxShadow: enabled
            ? <BoxShadow>[
                BoxShadow(
                  color: glow.withValues(alpha: 0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: content,
    );

    final Widget interactive = Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: radius,
          child: body,
        ),
      ),
    );

    if (heroTag != null) {
      return Hero(tag: heroTag!, child: interactive);
    }
    return interactive;
  }
}
