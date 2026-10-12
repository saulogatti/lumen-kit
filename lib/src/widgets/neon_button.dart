import 'package:material_ui/material_ui.dart';

import '../theme/neon_palette.dart';

/// Variantes visuais do [NeonButton].
enum NeonButtonVariant {
  /// Preenchido com gradiente neon. Equivale ao CTA primário.
  solid,

  /// Borda neon com fundo translúcido. Ação secundária.
  outline,

  /// Sem borda nem fundo — apenas texto/ícone com cor de accent. Ação terciária.
  ghost,
}

/// Botão neon com três variantes: [NeonButtonVariant.solid],
/// [NeonButtonVariant.outline] e [NeonButtonVariant.ghost].
///
/// Para o CTA primário com gradiente cheio, prefira [NeonButtonVariant.solid]
/// (ou o atalho histórico `GradientCta`).
class NeonButton extends StatelessWidget {
  /// Cria um botão neon na [variant] informada.
  const NeonButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = NeonButtonVariant.solid,
    this.icon,
    this.busy = false,
    this.accentColor,
    this.borderRadius = 14,
    this.expand = false,
  });

  /// Atalho para [NeonButtonVariant.outline].
  const NeonButton.outline({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.busy = false,
    this.accentColor,
    this.borderRadius = 14,
    this.expand = false,
  }) : variant = NeonButtonVariant.outline;

  /// Atalho para [NeonButtonVariant.ghost].
  const NeonButton.ghost({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.busy = false,
    this.accentColor,
    this.borderRadius = 14,
    this.expand = false,
  }) : variant = NeonButtonVariant.ghost;

  /// Texto exibido no botão.
  final String label;

  /// Callback executado ao tocar no botão.
  ///
  /// Quando `null`, o botão fica visualmente desabilitado.
  final VoidCallback? onPressed;

  /// Variante visual aplicada ao botão.
  final NeonButtonVariant variant;

  /// Ícone opcional exibido antes de [label].
  final IconData? icon;

  /// Se `true`, exibe indicador de progresso e bloqueia o toque.
  final bool busy;

  /// Override do accent. Default: `palette.accentCyan` para outline/ghost,
  /// `palette.accentGradient` para solid.
  final Color? accentColor;

  /// Raio dos cantos do botão em pixels lógicos.
  final double borderRadius;

  /// Se `true`, ocupa toda a largura disponível.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final NeonPalette palette = NeonThemeExt.of(context).palette;
    final bool enabled = onPressed != null && !busy;
    final Color accent = accentColor ?? palette.accentCyan;

    final Widget content = _buildContent(context, palette, accent);

    final Widget body = switch (variant) {
      NeonButtonVariant.solid => _solid(context, palette, content, enabled),
      NeonButtonVariant.outline => _outline(palette, accent, content, enabled),
      NeonButtonVariant.ghost => _ghost(content),
    };

    return Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(borderRadius),
          child: body,
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    NeonPalette palette,
    Color accent,
  ) {
    final Color fg = switch (variant) {
      NeonButtonVariant.solid => palette.backgroundDeep,
      NeonButtonVariant.outline || NeonButtonVariant.ghost => accent,
    };

    final List<Widget> children = <Widget>[
      if (busy)
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: fg),
        )
      else if (icon != null)
        Icon(icon, color: fg, size: 18),
      if (busy || icon != null) const SizedBox(width: 10),
      Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg),
      ),
    ];

    return Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: expand
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: children,
    );
  }

  Widget _solid(
    BuildContext context,
    NeonPalette palette,
    Widget content,
    bool enabled,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        gradient: palette.accentGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: enabled
            ? <BoxShadow>[
                BoxShadow(
                  color: (accentColor ?? palette.accentMagenta).withValues(
                    alpha: 0.35,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: content,
    );
  }

  Widget _outline(
    NeonPalette palette,
    Color accent,
    Widget content,
    bool enabled,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: accent.withValues(alpha: 0.85), width: 1.2),
        boxShadow: enabled
            ? <BoxShadow>[
                BoxShadow(
                  color: accent.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: content,
    );
  }

  Widget _ghost(Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: content,
    );
  }
}
