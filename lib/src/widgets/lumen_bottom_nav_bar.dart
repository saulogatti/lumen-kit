import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../foundation/lumen_pressable.dart';
import '../foundation/lumen_tokens.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';
import 'lumen_badge.dart';

/// Item de [LumenBottomNavBar] / [LumenNavRail].
class LumenNavItem {
  /// Cria um item compartilhado pela navegação inferior e lateral.
  const LumenNavItem({required this.icon, required this.label, this.badge});

  /// Ícone exibido no item de navegação.
  final IconData icon;

  /// Texto exibido abaixo do ícone.
  final String label;

  /// Pequeno texto exibido como badge sobre o ícone (ex: "3", "•").
  final String? badge;
}

/// Barra inferior com 3-5 itens, item selecionado destacado com pílula glow.
class LumenBottomNavBar extends StatelessWidget {
  /// Cria uma barra de navegação inferior.
  ///
  /// Use entre 3 e 5 [items] para manter a leitura e o toque confortáveis.
  const LumenBottomNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
    this.accentColor,
  });

  /// Itens exibidos na barra.
  final List<LumenNavItem> items;

  /// Índice do item atualmente selecionado.
  final int selectedIndex;

  /// Callback chamado com o índice do item tocado.
  final ValueChanged<int> onChanged;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
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
            final selected = i == selectedIndex;
            final LumenNavItem it = items[i];
            return Expanded(
              child: LumenPressable(
                onTap: () => onChanged(i),
                selected: selected,
                borderRadius: style.radius(20),
                child: AnimatedContainer(
                  duration: LumenMotion.duration(context, kLumenMediumDuration),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 6,
                  ),
                  decoration: LumenDecorations.selectable(
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
class LumenNavRail extends StatelessWidget {
  /// Cria a variante lateral da navegação neon.
  const LumenNavRail({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
    this.accentColor,
    this.leading,
    this.trailing,
  });

  /// Itens exibidos no rail.
  final List<LumenNavItem> items;

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
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
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
                  final selected = i == selectedIndex;
                  final LumenNavItem it = items[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: LumenPressable(
                      onTap: () => onChanged(i),
                      selected: selected,
                      borderRadius: style.radius(16),
                      child: AnimatedContainer(
                        duration: LumenMotion.duration(
                          context,
                          kLumenMediumDuration,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: LumenDecorations.selectable(
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

/// Ícone (com badge) + rótulo de um [LumenNavItem]. Compartilhado pela barra
/// inferior e pelo rail, que antes ignorava o `badge`.
class _NavItemContent extends StatelessWidget {
  const _NavItemContent({
    required this.item,
    required this.selected,
    required this.accent,
    this.iconSize,
  });

  final LumenNavItem item;
  final bool selected;
  final Color accent;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
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
                child: LumenBadge(label: badge, color: p.danger, dense: true),
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
