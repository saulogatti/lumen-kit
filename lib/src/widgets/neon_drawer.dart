import 'package:material_ui/material_ui.dart';

import '../theme/neon_palette.dart';

/// Drawer lateral com fundo em gradiente e borda accent vertical.
///
/// Use diretamente em `Scaffold(drawer: NeonDrawer(...))`. Os filhos podem ser
/// quaisquer widgets — geralmente um header customizado seguido de
/// [NeonDrawerItem]s.
class NeonDrawer extends StatelessWidget {
  /// Cria um drawer neon com lista de [children].
  const NeonDrawer({
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

  /// Override da cor de destaque. Default: `palette.accentCyan`.
  final Color? accentColor;

  /// Largura do drawer em pixels lógicos.
  final double width;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final Color accent = accentColor ?? p.accentCyan;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: width,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              p.backgroundMid.withValues(alpha: 0.98),
              p.backgroundDeep.withValues(alpha: 0.98),
            ],
          ),
          border: Border(
            right: BorderSide(
              color: accent.withValues(alpha: 0.55),
              width: 1.2,
            ),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accent.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(4, 0),
            ),
          ],
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

/// Item padronizado para [NeonDrawer], com glow no estado selecionado.
class NeonDrawerItem extends StatelessWidget {
  /// Cria um item interativo para uso dentro de [NeonDrawer].
  const NeonDrawerItem({
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

  /// Override da cor de destaque. Default: `palette.accentCyan`.
  final Color? accentColor;

  /// Widget opcional exibido no fim da linha.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final Color accent = accentColor ?? p.accentCyan;
    final bool disabled = onTap == null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Opacity(
        opacity: disabled ? 0.55 : 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: selected
                  ? accent.withValues(alpha: 0.16)
                  : Colors.transparent,
              border: Border.all(
                color: selected
                    ? accent.withValues(alpha: 0.55)
                    : Colors.transparent,
              ),
              boxShadow: selected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: accent.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: -2,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: <Widget>[
                Icon(icon, color: selected ? accent : p.textMuted, size: 20),
                const SizedBox(width: 14),
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
      ),
    );
  }
}
