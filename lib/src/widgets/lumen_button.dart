import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_action_content.dart';
import '../foundation/lumen_pressable.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Variantes visuais do [LumenButton].
enum LumenButtonVariant {
  /// Preenchido com gradiente neon. Equivale ao CTA primário.
  solid,

  /// Borda neon com fundo translúcido. Ação secundária.
  outline,

  /// Sem borda nem fundo — apenas texto/ícone com cor de accent. Ação terciária.
  ghost,
}

/// Botão neon com três variantes: [LumenButtonVariant.solid],
/// [LumenButtonVariant.outline] e [LumenButtonVariant.ghost].
///
/// Para o CTA primário com gradiente cheio, prefira [LumenButtonVariant.solid]
/// (ou o atalho histórico `LumenCta`).
class LumenButton extends StatelessWidget {
  /// Cria um botão neon na [variant] informada.
  const LumenButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = LumenButtonVariant.solid,
    this.icon,
    this.busy = false,
    this.accentColor,
    this.borderRadius = 14,
    this.expand = false,
  });

  /// Atalho para [LumenButtonVariant.outline].
  const LumenButton.outline({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.busy = false,
    this.accentColor,
    this.borderRadius = 14,
    this.expand = false,
  }) : variant = LumenButtonVariant.outline;

  /// Atalho para [LumenButtonVariant.ghost].
  const LumenButton.ghost({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.busy = false,
    this.accentColor,
    this.borderRadius = 14,
    this.expand = false,
  }) : variant = LumenButtonVariant.ghost;

  /// Texto exibido no botão.
  final String label;

  /// Callback executado ao tocar no botão.
  ///
  /// Quando `null`, o botão fica visualmente desabilitado.
  final VoidCallback? onPressed;

  /// Variante visual aplicada ao botão.
  final LumenButtonVariant variant;

  /// Ícone opcional exibido antes de [label].
  final IconData? icon;

  /// Se `true`, exibe indicador de progresso e bloqueia o toque.
  final bool busy;

  /// Override do accent. Default: `palette.primary` para outline/ghost,
  /// `palette.accentGradient` para solid.
  final Color? accentColor;

  /// Raio dos cantos do botão em pixels lógicos.
  final double borderRadius;

  /// Se `true`, ocupa toda a largura disponível.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final LumenPalette palette = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final bool enabled = onPressed != null && !busy;
    final Color accent = accentColor ?? palette.primary;

    final Widget content = _buildContent(palette, accent);

    final Widget body = switch (variant) {
      LumenButtonVariant.solid => _solid(context, palette, content, enabled),
      LumenButtonVariant.outline => _outline(
        context,
        palette,
        accent,
        content,
        enabled,
      ),
      LumenButtonVariant.ghost => _ghost(content),
    };

    return LumenPressable(
      onTap: onPressed,
      enabled: !busy,
      borderRadius: style.radius(borderRadius),
      child: body,
    );
  }

  Widget _buildContent(LumenPalette palette, Color accent) {
    final Color fg = switch (variant) {
      LumenButtonVariant.solid => palette.backgroundDeep,
      LumenButtonVariant.outline || LumenButtonVariant.ghost => accent,
    };

    return LumenActionContent(
      color: fg,
      label: label,
      icon: icon,
      busy: busy,
      expand: expand,
    );
  }

  Widget _solid(
    BuildContext context,
    LumenPalette palette,
    Widget content,
    bool enabled,
  ) {
    final LumenStyle style = LumenStyle.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        gradient: style.fill(palette.accentGradient),
        borderRadius: style.radius(borderRadius),
        boxShadow: style.shadows(
          enabled
              ? <BoxShadow>[
                  BoxShadow(
                    color: (accentColor ?? palette.secondary).withValues(
                      alpha: 0.35,
                    ),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
      ),
      child: content,
    );
  }

  Widget _outline(
    BuildContext context,
    LumenPalette palette,
    Color accent,
    Widget content,
    bool enabled,
  ) {
    final LumenStyle style = LumenStyle.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: style.surfaceAlpha(0.35)),
        borderRadius: style.radius(borderRadius),
        border: style.borderAll(
          color: accent.withValues(alpha: 0.85),
          width: 1.2,
        ),
        boxShadow: style.shadows(
          enabled
              ? <BoxShadow>[
                  BoxShadow(
                    color: accent.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
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
