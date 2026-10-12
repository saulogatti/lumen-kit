import 'package:material_ui/material_ui.dart';

import '../foundation/neon_decorations.dart';
import '../foundation/neon_pressable.dart';
import '../foundation/neon_tokens.dart';
import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';
import 'neon_badge.dart';

/// Item de [NeonBottomNavBar] / [NeonNavRail].
class NeonNavItem {
  /// Cria um item compartilhado pela navegação inferior e lateral.
  const NeonNavItem({required this.icon, required this.label, this.badge});

  /// Ícone exibido no item de navegação.
  final IconData icon;

  /// Texto exibido abaixo do ícone.
  final String label;

  /// Pequeno texto exibido como badge sobre o ícone (ex: "3", "•").
  final String? badge;
}

/// Barra inferior com 3-5 itens, item selecionado destacado com pílula glow.
class NeonBottomNavBar extends StatelessWidget {
  /// Cria uma barra de navegação inferior.
  ///
  /// Use entre 3 e 5 [items] para manter a leitura e o toque confortáveis.
  const NeonBottomNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
    this.accentColor,
  });

  /// Itens exibidos na barra.
  final List<NeonNavItem> items;

  /// Índice do item atualmente selecionado.
  final int selectedIndex;

  /// Callback chamado com o índice do item tocado.
  final ValueChanged<int> onChanged;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Color accent = accentColor ?? p.primary;

    return Container(
      decoration: BoxDecoration(
        color: p.backgroundMid.withValues(alpha: style.surfaceAlpha(0.95)),
        border: Border(
          top: BorderSide(color: p.surfaceOutline.withValues(alpha: 0.5)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          children: List<Widget>.generate(items.length, (int i) {
            final bool selected = i == selectedIndex;
            final NeonNavItem it = items[i];
            return Expanded(
              child: NeonPressable(
                onTap: () => onChanged(i),
                selected: selected,
                borderRadius: style.radius(20),
                child: AnimatedContainer(
                  duration: NeonMotion.duration(context, kNeonMediumDuration),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 6,
                  ),
                  decoration: NeonDecorations.selectable(
                    p,
                    style,
                    accent: accent,
                    selected: selected,
                    radius: 20,
                  ),
                  child: _NavItemContent(
                    item: it,
                    selected: selected,
                    accent: accent,
                    iconSize: 22,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Variante lateral (tablet / desktop).
class NeonNavRail extends StatelessWidget {
  /// Cria a variante lateral da navegação neon.
  const NeonNavRail({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
    this.accentColor,
    this.leading,
    this.trailing,
  });

  /// Itens exibidos no rail.
  final List<NeonNavItem> items;

  /// Índice do item atualmente selecionado.
  final int selectedIndex;

  /// Callback chamado com o índice do item tocado.
  final ValueChanged<int> onChanged;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  /// Widget opcional exibido acima da lista.
  final Widget? leading;

  /// Widget opcional exibido abaixo da lista.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Color accent = accentColor ?? p.primary;

    return Container(
      width: 84,
      decoration: BoxDecoration(
        color: p.backgroundMid.withValues(alpha: style.surfaceAlpha(0.95)),
        border: Border(
          right: BorderSide(color: p.surfaceOutline.withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            if (leading case final Widget leading) ...<Widget>[
              const SizedBox(height: 12),
              leading,
            ],
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemBuilder: (BuildContext _, int i) {
                  final bool selected = i == selectedIndex;
                  final NeonNavItem it = items[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: NeonPressable(
                      onTap: () => onChanged(i),
                      selected: selected,
                      borderRadius: style.radius(16),
                      child: AnimatedContainer(
                        duration: NeonMotion.duration(
                          context,
                          kNeonMediumDuration,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: NeonDecorations.selectable(
                          p,
                          style,
                          accent: accent,
                          selected: selected,
                          radius: 16,
                          glow: false,
                        ),
                        child: _NavItemContent(
                          item: it,
                          selected: selected,
                          accent: accent,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (trailing case final Widget trailing) ...<Widget>[
              trailing,
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

/// Ícone (com badge) + rótulo de um [NeonNavItem]. Compartilhado pela barra
/// inferior e pelo rail, que antes ignorava o `badge`.
class _NavItemContent extends StatelessWidget {
  const _NavItemContent({
    required this.item,
    required this.selected,
    required this.accent,
    this.iconSize,
  });

  final NeonNavItem item;
  final bool selected;
  final Color accent;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final Widget icon = Icon(
      item.icon,
      color: selected ? accent : p.textMuted,
      size: iconSize,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: <Widget>[
        if (item.badge case final String badge)
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              icon,
              Positioned(
                right: -6,
                top: -4,
                child: NeonBadge(label: badge, color: p.danger, dense: true),
              ),
            ],
          )
        else
          icon,
        Text(
          item.label,
          style: TextStyle(
            fontSize: 11,
            color: selected ? p.textPrimary : p.textMuted,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
