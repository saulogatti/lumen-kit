import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_pressable.dart';
import '../foundation/lumen_tokens.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// ListTile temático com surface translúcida, borda accent suave e estado
/// selecionado destacado por glow.
class LumenListTile extends StatelessWidget {
  /// Cria um item de lista neon.
  const LumenListTile({
    required this.title,
    super.key,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.accentColor,
    this.dense = false,
  });

  /// Texto principal do item.
  final String title;

  /// Texto auxiliar exibido abaixo de [title].
  final String? subtitle;

  /// Widget opcional exibido antes do texto.
  final Widget? leading;

  /// Widget opcional exibido no fim da linha.
  final Widget? trailing;

  /// Callback executado ao tocar no item.
  final VoidCallback? onTap;

  /// Callback executado no toque longo.
  final VoidCallback? onLongPress;

  /// Se `true`, aplica destaque visual de seleção.
  final bool selected;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  /// Se `true`, reduz o espaçamento vertical.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final Color accent = accentColor ?? p.primary;
    final bool disabled = onTap == null && onLongPress == null;

    // Tile sem ação é só informativo: apaga menos que um controle
    // desabilitado (0.7 em vez de kLumenDisabledOpacity).
    return Opacity(
      opacity: disabled && !selected ? 0.7 : 1,
      child: LumenPressable(
        onTap: onTap,
        onLongPress: onLongPress,
        selected: selected,
        button: !disabled,
        dimWhenDisabled: false,
        borderRadius: style.radius(14),
        child: AnimatedContainer(
          duration: LumenMotion.duration(context, kLumenFastDuration),
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: dense ? 8 : 12,
          ),
          decoration: BoxDecoration(
            borderRadius: style.radius(14),
            color: selected
                ? accent.withValues(alpha: 0.14)
                : p.surface.withValues(alpha: style.surfaceAlpha(0.5)),
            border: style.borderAll(
              color: selected
                  ? accent.withValues(alpha: 0.6)
                  : p.surfaceOutline.withValues(alpha: 0.45),
            ),
            boxShadow: style.shadows(
              selected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: accent.withValues(alpha: 0.28),
                        blurRadius: 14,
                        spreadRadius: -3,
                      ),
                    ]
                  : null,
            ),
          ),
          child: Row(
            children: <Widget>[
              if (leading case final Widget leading) ...<Widget>[
                leading,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: p.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle case final String subtitle) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: p.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing case final Widget trailing) ...<Widget>[
                const SizedBox(width: 8),
                trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
