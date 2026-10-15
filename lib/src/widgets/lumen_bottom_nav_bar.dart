import 'package:lumen_kit/src/foundation/lumen_decorations.dart';
import 'package:lumen_kit/src/foundation/lumen_pressable.dart';
import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:lumen_kit/src/widgets/lumen_badge.dart';
import 'package:material_ui/material_ui.dart';

/// Item from [LumenBottomNavBar] / [LumenNavRail].
class LumenNavItem {
  /// Creates an item shared by bottom and side navigation.
  const LumenNavItem({required this.icon, required this.label, this.badge});

  /// Icon displayed in the navigation item.
  final IconData icon;

  /// Text displayed below the icon.
  final String label;

  /// Small text displayed as a badge over the icon (ex: "3", "•").
  final String? badge;
}

/// Bottom bar with 3-5 items, selected item highlighted with glow pill.
class LumenBottomNavBar extends StatelessWidget {
  /// Creates a bottom navigation bar.
  /// Use between 3 and 5 [items] to keep reading and touching comfortable.
  const LumenBottomNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
    this.accentColor,
  });

  /// Items displayed in the bar.
  final List<LumenNavItem> items;

  /// Index of the currently selected item.
  final int selectedIndex;

  /// Callback called with the index of the touched item.
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
      decoration: BoxDecoration(
        color: p.backgroundMid.withValues(alpha: style.surfaceAlpha(0.95)),
        border: Border(
          top: BorderSide(color: p.surfaceOutline.outlineAlpha(0.5)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          children: List<Widget>.generate(items.length, (i) {
            final selected = i == selectedIndex;
            final it = items[i];
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

/// Side variant (tablet/desktop).
class LumenNavRail extends StatelessWidget {
  /// Creates the side variant of the neon navigation.
  const LumenNavRail({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
    this.accentColor,
    this.leading,
    this.trailing,
  });

  /// Items displayed on the rail.
  final List<LumenNavItem> items;

  /// Index of the currently selected item.
  final int selectedIndex;

  /// Callback called with the index of the touched item.
  final ValueChanged<int> onChanged;

  /// Highlight color override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Optional widget displayed above the list.
  final Widget? leading;

  /// Optional widget displayed below the list.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final accent = accentColor ?? p.primary;

    return Container(
      width: 84,
      decoration: BoxDecoration(
        color: p.backgroundMid.withValues(alpha: style.surfaceAlpha(0.95)),
        border: Border(
          right: BorderSide(color: p.surfaceOutline.outlineAlpha(0.5)),
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
                itemBuilder: (_, i) {
                  final selected = i == selectedIndex;
                  final it = items[i];
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

/// Icon (with badge) + label of a [LumenNavItem].
///
/// Shared by bar lower and through the rail, which previously ignored `badge`.
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
    final p = LumenThemeExt.of(context).palette;
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
