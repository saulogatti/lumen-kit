import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../foundation/lumen_pressable.dart';
import '../foundation/lumen_tokens.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Drawer lateral com fundo em gradiente e borda accent vertical.
///
/// Use diretamente em `Scaffold(drawer: LumenDrawer(...))`. Os filhos podem ser
/// quaisquer widgets — geralmente um header customizado seguido de
/// [LumenDrawerItem]s.
class LumenDrawer extends StatelessWidget {
  /// Cria um drawer neon com lista de [children].
  const LumenDrawer({
    required this.children,
    super.key,
    this.accentColor,
    this.header,
    this.footer,
    this.width = 300,
  });

  /// Widgets exibidos na área rolável do drawer.
  final List<Widget> children;

  /// Cabeçalho opcional exibido antes da lista.
  final Widget? header;

  /// Rodapé opcional exibido após a lista.
  final Widget? footer;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  /// Largura do drawer em pixels lógicos.
  final double width;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final Color accent = accentColor ?? p.primary;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: width,
      child: Container(
        decoration: BoxDecoration(
          gradient: style.fill(
            LumenDecorations.diagonal(
              p.backgroundMid.withValues(alpha: style.surfaceAlpha(0.98)),
              p.backgroundDeep.withValues(alpha: 0.98),
            ),
          ),
          border: Border(
            right: BorderSide(
              color: accent.withValues(alpha: 0.55),
              width: 1.2,
            ),
          ),
          boxShadow: style.shadows(<BoxShadow>[
            BoxShadow(
              color: accent.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(4, 0),
            ),
          ]),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              ?header,
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  children: children,
                ),
              ),
              ?footer,
            ],
          ),
        ),
      ),
    );
  }
}

/// Item padronizado para [LumenDrawer], com glow no estado selecionado.
class LumenDrawerItem extends StatelessWidget {
  /// Cria um item interativo para uso dentro de [LumenDrawer].
  const LumenDrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
    this.selected = false,
    this.accentColor,
    this.trailing,
  });

  /// Ícone exibido antes do texto.
  final IconData icon;

  /// Texto principal do item.
  final String label;

  /// Callback executado ao tocar no item.
  ///
  /// Quando `null`, o item fica visualmente desabilitado.
  final VoidCallback? onTap;

  /// Se `true`, aplica destaque visual de seleção.
  final bool selected;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  /// Widget opcional exibido no fim da linha.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final Color accent = accentColor ?? p.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: LumenPressable(
        onTap: onTap,
        selected: selected,
        borderRadius: style.radius(14),
        child: AnimatedContainer(
          duration: LumenMotion.duration(context, kLumenFastDuration),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: LumenDecorations.selectable(
            p,
            style,
            accent: accent,
            selected: selected,
            radius: 14,
          ),
          child: Row(
            spacing: 14,
            children: <Widget>[
              Icon(icon, color: selected ? accent : p.textMuted, size: 20),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? p.textPrimary : p.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
