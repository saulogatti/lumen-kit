import 'package:lumen_kit/src/foundation/lumen_decorations.dart';
import 'package:lumen_kit/src/foundation/lumen_pressable.dart';
import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Item from [LumenTabs] / [LumenSegmentedControl].
class LumenTabItem {
  /// Creates a tab item with optional text and icon.
  const LumenTabItem({required this.label, this.icon});

  /// Text displayed in the tab.
  final String label;

  /// Optional icon displayed above or before [label].
  final IconData? icon;
}

/// Horizontal tabs with accent gradient indicator.
/// Controlled: indicator tracks [selectedIndex] even when it changes from the
/// outside (e.g. swipe on a `PageView` or programmatic navigation).
class LumenTabs extends StatefulWidget {
  /// Creates a tab bar controlled by [selectedIndex].
  const LumenTabs({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
    this.accentColor,
    this.isScrollable = false,
  });

  /// Items displayed in the bar.
  final List<LumenTabItem> items;

  /// Index of the selected tab, limited to the valid range.
  final int selectedIndex;

  /// Callback called with the index of the tab played.
  final ValueChanged<int> onChanged;

  /// Highlight color override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Whether to allow horizontal scrolling of tabs.
  final bool isScrollable;

  @override
  State<LumenTabs> createState() => _LumenTabsState();
}

class _LumenTabsState extends State<LumenTabs> with TickerProviderStateMixin {
  late TabController _controller = _create();

  int get _index => widget.selectedIndex.clamp(0, widget.items.length - 1);

  TabController _create() =>
      TabController(length: widget.items.length, initialIndex: _index, vsync: this);

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
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final accent = widget.accentColor ?? p.primary;

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
      overlayColor: WidgetStatePropertyAll<Color>(accent.withValues(alpha: 0.08)),
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

/// Segmented control compact (pill).
///
/// Items share width equally.
class LumenSegmentedControl extends StatelessWidget {
  /// Creates a segmented control with index selection.
  const LumenSegmentedControl({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
    this.accentColor,
  });

  /// Segments displayed in the control.
  final List<LumenTabItem> items;

  /// Index of the selected segment.
  final int selectedIndex;

  /// Callback called with the index of the played segment.
  final ValueChanged<int> onChanged;

  /// Highlight color override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final accent = accentColor ?? p.primary;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.surface.withValues(alpha: style.surfaceAlpha(0.7)),
        borderRadius: style.radius(28),
        border: style.borderAll(color: p.surfaceOutline.outlineAlpha(0.6)),
      ),
      child: Row(
        children: List<Widget>.generate(items.length, (i) {
          final selected = i == selectedIndex;
          final it = items[i];
          final fg = selected ? p.textPrimary : p.textMuted;
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
                  gradient: style.fill(selected ? LumenDecorations.accent(p, accent) : null),
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
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
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
