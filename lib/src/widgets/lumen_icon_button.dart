import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_action_content.dart';
import '../foundation/lumen_pressable.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Variantes visuais do [LumenIconButton].
enum LumenIconButtonVariant {
  /// Preenchido com gradiente neon.
  solid,

  /// Borda neon com fundo translúcido.
  outline,

  /// Apenas ícone na cor de accent, sem fundo nem borda.
  ghost,
}

/// Botão circular/quadrado contendo apenas um ícone, no estilo neon.
class LumenIconButton extends StatelessWidget {
  /// Cria um botão de ícone na variante [variant].
  const LumenIconButton({
    required this.icon,
    required this.onPressed,
    super.key,
    this.variant = LumenIconButtonVariant.outline,
    this.tooltip,
    this.busy = false,
    this.accentColor,
    this.size = 44,
    this.iconSize = 20,
    this.shape = LumenIconButtonShape.circle,
    this.semanticLabel,
  });

  /// Atalho para [LumenIconButtonVariant.solid].
  const LumenIconButton.solid({
    required this.icon,
    required this.onPressed,
    super.key,
    this.tooltip,
    this.busy = false,
    this.accentColor,
    this.size = 44,
    this.iconSize = 20,
    this.shape = LumenIconButtonShape.circle,
    this.semanticLabel,
  }) : variant = LumenIconButtonVariant.solid;

  /// Atalho para [LumenIconButtonVariant.ghost].
  const LumenIconButton.ghost({
    required this.icon,
    required this.onPressed,
    super.key,
    this.tooltip,
    this.busy = false,
    this.accentColor,
    this.size = 44,
    this.iconSize = 20,
    this.shape = LumenIconButtonShape.circle,
    this.semanticLabel,
  }) : variant = LumenIconButtonVariant.ghost;

  /// Ícone exibido no botão.
  final IconData icon;

  /// Callback executado ao tocar no botão.
  ///
  /// Quando `null`, o botão fica visualmente desabilitado.
  final VoidCallback? onPressed;

  /// Variante visual aplicada ao botão.
  final LumenIconButtonVariant variant;

  /// Mensagem opcional exibida em um [Tooltip].
  final String? tooltip;

  /// Se `true`, exibe indicador de progresso e bloqueia o toque.
  final bool busy;

  /// Override do accent. Default: `palette.primary`.
  final Color? accentColor;

  /// Tamanho da área total (largura = altura).
  final double size;

  /// Tamanho do ícone ou do indicador de progresso.
  final double iconSize;

  /// Formato do botão: círculo ou quadrado arredondado.
  final LumenIconButtonShape shape;

  /// Rótulo para leitores de tela quando não há [tooltip].
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final LumenPalette palette = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final bool enabled = onPressed != null && !busy;
    final Color accent = accentColor ?? palette.primary;

    final BorderRadius radius = switch (shape) {
      LumenIconButtonShape.circle => style.radius(size / 2),
      LumenIconButtonShape.rounded => style.radius(12),
    };

    final Color fg = variant == LumenIconButtonVariant.solid
        ? palette.backgroundDeep
        : accent;

    final Widget content = Center(
      child: LumenActionContent(
        color: fg,
        icon: icon,
        busy: busy,
        iconSize: iconSize,
        spinnerSize: iconSize,
      ),
    );

    final Widget body = switch (variant) {
      LumenIconButtonVariant.solid => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: style.fill(palette.accentGradient),
          borderRadius: radius,
          boxShadow: style.shadows(
            enabled
                ? <BoxShadow>[
                    BoxShadow(
                      color: (accentColor ?? palette.secondary).withValues(
                        alpha: 0.35,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
        ),
        child: content,
      ),
      LumenIconButtonVariant.outline => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: palette.surface.withValues(alpha: style.surfaceAlpha(0.35)),
          borderRadius: radius,
          border: style.borderAll(
            color: accent.withValues(alpha: 0.85),
            width: 1.2,
          ),
          boxShadow: style.shadows(
            enabled
                ? <BoxShadow>[
                    BoxShadow(
                      color: accent.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
        ),
        child: content,
      ),
      LumenIconButtonVariant.ghost => SizedBox(
        width: size,
        height: size,
        child: content,
      ),
    };

    final Widget interactive = LumenPressable(
      onTap: onPressed,
      enabled: !busy,
      borderRadius: radius,
      // Com tooltip o Tooltip já anuncia a mensagem.
      semanticLabel: tooltip == null ? semanticLabel : null,
      child: body,
    );

    return tooltip == null
        ? interactive
        : Tooltip(message: tooltip, child: interactive);
  }
}

/// Formato do [LumenIconButton].
enum LumenIconButtonShape {
  /// Botão circular.
  circle,

  /// Botão quadrado com cantos arredondados.
  rounded,
}
