import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../foundation/lumen_pressable.dart';
import '../foundation/lumen_tokens.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Item de [LumenTabs] / [LumenSegmentedControl].
class LumenTabItem {
  /// Cria um item de tab com texto e ícone opcional.
  const LumenTabItem({required this.label, this.icon});

  /// Texto exibido na tab.
  final String label;

  /// Ícone opcional exibido acima ou antes de [label].
  final IconData? icon;
}

/// Tabs horizontais com indicador em gradiente accent.
///
/// Controlado: o indicador acompanha [selectedIndex] mesmo quando ele muda
/// por fora (ex.: swipe num `PageView` ou navegação programática).
class LumenTabs extends StatefulWidget {
  /// Cria uma barra de tabs controlada por [selectedIndex].
  const LumenTabs({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
    this.accentColor,
    this.isScrollable = false,
  });

  /// Itens exibidos na barra.
  final List<LumenTabItem> items;

  /// Índice da tab selecionada, limitado ao intervalo válido.
  final int selectedIndex;

  /// Callback chamado com o índice da tab tocada.
  final ValueChanged<int> onChanged;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  /// Se `true`, permite rolagem horizontal das tabs.
  final bool isScrollable;

  @override
  State<LumenTabs> createState() => _LumenTabsState();
}

class _LumenTabsState extends State<LumenTabs> with TickerProviderStateMixin {
  late TabController _controller = _create();

  int get _index => widget.selectedIndex.clamp(0, widget.items.length - 1);

  TabController _create() => TabController(
    length: widget.items.length,
    initialIndex: _index,
    vsync: this,
  );

  @override
  void didUpdateWidget(LumenTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _controller.dispose();
      _controller = _create();
    } else if (_controller.index != _index) {
      _controller.animateTo(_index);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final Color accent = widget.accentColor ?? p.primary;

    return TabBar(
      controller: _controller,
      isScrollable: widget.isScrollable,
      onTap: widget.onChanged,
      labelColor: p.textPrimary,
      unselectedLabelColor: p.textMuted,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: accent, width: 2.5),
        insets: const EdgeInsets.symmetric(horizontal: 4),
      ),
      overlayColor: WidgetStatePropertyAll<Color>(
        accent.withValues(alpha: 0.08),
      ),
      splashBorderRadius: style.radius(10),
      tabs: <Widget>[
        for (final LumenTabItem it in widget.items)
          Tab(
            icon: it.icon == null ? null : Icon(it.icon),
            text: it.label,
            iconMargin: const EdgeInsets.only(bottom: 4),
          ),
      ],
    );
  }
}

/// Segmented control compacto (pílula). Os itens dividem largura igualmente.
class LumenSegmentedControl extends StatelessWidget {
  /// Cria um controle segmentado com seleção por índice.
  const LumenSegmentedControl({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
    this.accentColor,
  });

  /// Segmentos exibidos no controle.
  final List<LumenTabItem> items;

  /// Índice do segmento selecionado.
  final int selectedIndex;

  /// Callback chamado com o índice do segmento tocado.
  final ValueChanged<int> onChanged;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
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
          final selected = i == selectedIndex;
          final LumenTabItem it = items[i];
          final Color fg = selected ? p.textPrimary : p.textMuted;
          return Expanded(
            child: LumenPressable(
              onTap: () => onChanged(i),
              selected: selected,
              borderRadius: style.radius(24),
              child: AnimatedContainer(
                duration: LumenMotion.duration(context, kLumenMediumDuration),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: style.radius(24),
                  gradient: style.fill(
                    selected ? LumenDecorations.accent(p, accent) : null,
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
                  spacing: 6,
                  children: <Widget>[
                    if (it.icon != null) Icon(it.icon, size: 16, color: fg),
                    Text(
                      it.label,
                      style: TextStyle(
                        color: fg,
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
