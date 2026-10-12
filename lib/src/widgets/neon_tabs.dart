import 'package:material_ui/material_ui.dart';

import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Item de [NeonTabs] / [NeonSegmentedControl].
class NeonTabItem {
  /// Cria um item de tab com texto e ícone opcional.
  const NeonTabItem({required this.label, this.icon});

  /// Texto exibido na tab.
  final String label;

  /// Ícone opcional exibido acima ou antes de [label].
  final IconData? icon;
}

/// Tabs horizontais com indicador em gradiente accent.
class NeonTabs extends StatelessWidget {
  /// Cria uma barra de tabs controlada por [selectedIndex].
  const NeonTabs({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
    this.accentColor,
    this.isScrollable = false,
  });

  /// Itens exibidos na barra.
  final List<NeonTabItem> items;

  /// Índice da tab selecionada.
  ///
  /// O índice é limitado ao intervalo válido antes de inicializar o controller.
  final int selectedIndex;

  /// Callback chamado com o índice da tab tocada.
  final ValueChanged<int> onChanged;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  /// Se `true`, permite rolagem horizontal das tabs.
  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Color accent = accentColor ?? p.primary;

    return DefaultTabController(
      length: items.length,
      initialIndex: selectedIndex.clamp(0, items.length - 1),
      child: TabBar(
        isScrollable: isScrollable,
        onTap: onChanged,
        labelColor: p.textPrimary,
        unselectedLabelColor: p.textMuted,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: accent, width: 2.5),
          insets: const EdgeInsets.symmetric(horizontal: 4),
        ),
        overlayColor: WidgetStateProperty.all(accent.withValues(alpha: 0.08)),
        splashBorderRadius: style.radius(10),
        tabs: items
            .map(
              (NeonTabItem it) => Tab(
                icon: it.icon == null ? null : Icon(it.icon),
                text: it.label,
                iconMargin: const EdgeInsets.only(bottom: 4),
              ),
            )
            .toList(),
      ),
    );
  }
}

/// Segmented control compacto (pílula). Os itens dividem largura igualmente.
class NeonSegmentedControl extends StatelessWidget {
  /// Cria um controle segmentado com seleção por índice.
  const NeonSegmentedControl({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
    this.accentColor,
  });

  /// Segmentos exibidos no controle.
  final List<NeonTabItem> items;

  /// Índice do segmento selecionado.
  final int selectedIndex;

  /// Callback chamado com o índice do segmento tocado.
  final ValueChanged<int> onChanged;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Color accent = accentColor ?? p.primary;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.surface.withValues(alpha: style.surfaceAlpha(0.7)),
        borderRadius: style.radius(28),
        border: style.borderAll(color: p.surfaceOutline.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: List<Widget>.generate(items.length, (int i) {
          final bool selected = i == selectedIndex;
          final NeonTabItem it = items[i];
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: style.radius(24),
                  gradient: style.fill(
                    selected
                        ? LinearGradient(
                            colors: <Color>[accent, p.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                  ),
                  boxShadow: style.shadows(
                    selected
                        ? <BoxShadow>[
                            BoxShadow(
                              color: accent.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: -2,
                            ),
                          ]
                        : null,
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (it.icon != null) ...<Widget>[
                      Icon(
                        it.icon,
                        size: 16,
                        color: selected ? p.textPrimary : p.textMuted,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      it.label,
                      style: TextStyle(
                        color: selected ? p.textPrimary : p.textMuted,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
