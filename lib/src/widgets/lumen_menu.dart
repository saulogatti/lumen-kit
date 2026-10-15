import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_tokens.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';
import 'lumen_icon_button.dart';

/// Position for [showLumenMenu] at a global screen point (e.g.
/// `TapUpDetails.globalPosition` from a right-click).
RelativeRect lumenMenuPositionAt(BuildContext context, Offset globalPosition) {
  final overlay =
      Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
  final Offset local = overlay.globalToLocal(globalPosition);
  return RelativeRect.fromRect(local & Size.zero, Offset.zero & overlay.size);
}

/// Former name for [lumenMenuPositionAt].
@Deprecated('Use lumenMenuPositionAt')
RelativeRect neonMenuPositionAt(BuildContext context, Offset globalPosition) =>
    lumenMenuPositionAt(context, globalPosition);

/// Opens a floating menu with [items] and returns the selected value, or
/// `null` if the menu is dismissed without a selection.
///
/// Without [position], the menu opens anchored just below the widget that owns
/// [context] (such as the "⋮" on a card). To open at a screen point (e.g. a
/// right-click), use [lumenMenuPositionAt].
Future<T?> showLumenMenu<T>({
  required BuildContext context,
  required List<LumenMenuEntry<T>> items,
  RelativeRect? position,
  Color? accentColor,
  T? initialValue,
}) {
  assert(items.isNotEmpty, 'O menu precisa de ao menos uma entrada.');
  final LumenPalette p = LumenThemeExt.of(context).palette;
  final LumenStyle s = LumenStyle.of(context);
  final Color accent = accentColor ?? p.primary;
  final TextStyle? text = Theme.of(context).textTheme.bodyMedium;
  final Border border = s.borderAll(
    color: accent.withValues(alpha: 0.45),
    width: 1.2,
  );

  return showMenu<T>(
    context: context,
    position: position ?? _anchorBelow(context),
    initialValue: initialValue,
    color: p.surface.withValues(alpha: s.surfaceAlpha(0.98)),
    surfaceTintColor: Colors.transparent,
    elevation: s.shadow == LumenShadowKind.none ? 0 : 10,
    shadowColor: s.shadow == LumenShadowKind.glow
        ? accent.withValues(alpha: 0.45 * s.shadowStrength)
        : Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black54,
    shape: RoundedRectangleBorder(
      borderRadius: s.radius(14),
      side: s.borderScale == 0 ? BorderSide.none : border.top,
    ),
    clipBehavior: Clip.antiAlias,
    popUpAnimationStyle: LumenMotion.reduced(context)
        ? AnimationStyle.noAnimation
        : null,
    items: <PopupMenuEntry<T>>[
      for (final LumenMenuEntry<T> entry in items)
        switch (entry) {
          LumenMenuDivider<T>() => PopupMenuDivider(
            height: 9,
            color: p.surfaceOutline,
          ),
          final LumenMenuItem<T> item => PopupMenuItem<T>(
            value: item.value,
            enabled: item.enabled,
            height: 44,
            child: _LumenMenuRow(
              item: item,
              color: item.destructive ? p.danger : p.textPrimary,
              iconColor: item.destructive ? p.danger : accent,
              selected: initialValue != null && initialValue == item.value,
              selectedColor: accent,
              style: text,
            ),
          ),
        },
    ],
  );
}

RelativeRect _anchorBelow(BuildContext context) {
  final box = context.findRenderObject()! as RenderBox;
  final overlay =
      Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
  final Offset topLeft = box.localToGlobal(
    Offset(0, box.size.height),
    ancestor: overlay,
  );
  final Offset bottomRight = box.localToGlobal(
    box.size.bottomRight(Offset.zero),
    ancestor: overlay,
  );
  return RelativeRect.fromRect(
    Rect.fromPoints(topLeft, bottomRight),
    Offset.zero & overlay.size,
  );
}

/// Opens a context menu on right-click (desktop/web) or long-press (mobile)
/// over [child], at the pointer position.
///
/// Uses `GestureDetector` because it needs the pointer position, which
/// `LumenPressable` does not expose; screen readers open the menu with the
/// long-press action.
class LumenContextMenu<T> extends StatelessWidget {
  /// Creates the context menu region.
  const LumenContextMenu({
    required this.items,
    required this.onSelected,
    required this.child,
    super.key,
    this.accentColor,
  });

  /// Menu actions.
  final List<LumenMenuEntry<T>> items;

  /// Called with the value of the selected action. `null` disables the menu.
  final ValueChanged<T>? onSelected;

  /// Content that receives the gesture.
  final Widget child;

  /// Accent override. Default: `palette.primary`.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    if (onSelected == null) {
      return child;
    }
    return Semantics(
      onLongPress: () {
        final box = context.findRenderObject()! as RenderBox;
        _open(context, box.localToGlobal(box.size.center(Offset.zero)));
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onSecondaryTapUp: (TapUpDetails d) => _open(context, d.globalPosition),
        onLongPressStart: (LongPressStartDetails d) =>
            _open(context, d.globalPosition),
        child: child,
      ),
    );
  }

  Future<void> _open(BuildContext context, Offset global) async {
    final T? value = await showLumenMenu<T>(
      context: context,
      items: items,
      accentColor: accentColor,
      position: lumenMenuPositionAt(context, global),
    );
    if (value != null && context.mounted) {
      onSelected?.call(value);
    }
  }
}

/// "⋮" button (or another [icon]) that opens an action menu anchored to it.
/// For cards, list tiles, and app bars.
///
/// ```dart
/// LumenMenuButton<String>(
///   items: const <LumenMenuEntry<String>>[
///     LumenMenuItem(value: 'edit', label: 'Edit', icon: Icons.edit),
///     LumenMenuDivider(),
///     LumenMenuItem(value: 'del', label: 'Delete', destructive: true),
///   ],
///   onSelected: handle,
/// )
/// ```
class LumenMenuButton<T> extends StatelessWidget {
  /// Creates the menu button. It is disabled when [onSelected] is `null`.
  const LumenMenuButton({
    required this.items,
    required this.onSelected,
    super.key,
    this.icon = Icons.more_vert_rounded,
    this.tooltip,
    this.accentColor,
    this.initialValue,
    this.variant = LumenIconButtonVariant.ghost,
    this.size = 40,
    this.onCanceled,
  });

  /// Menu actions.
  final List<LumenMenuEntry<T>> items;

  /// Called with the value of the selected action.
  final ValueChanged<T>? onSelected;

  /// Called when the menu is dismissed without a selection.
  final VoidCallback? onCanceled;

  /// Button icon.
  final IconData icon;

  /// Button tooltip. Default: Material's "show menu" label.
  final String? tooltip;

  /// Accent override. Default: `palette.primary`.
  final Color? accentColor;

  /// Value marked with a check in the menu.
  final T? initialValue;

  /// Button visual variant.
  final LumenIconButtonVariant variant;

  /// Button side.
  final double size;

  @override
  Widget build(BuildContext context) {
    return LumenIconButton(
      icon: icon,
      variant: variant,
      size: size,
      accentColor: accentColor,
      tooltip: tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
      onPressed: onSelected == null
          ? null
          : () async {
              final T? value = await showLumenMenu<T>(
                context: context,
                items: items,
                accentColor: accentColor,
                initialValue: initialValue,
              );
              if (!context.mounted) {
                return;
              }
              if (value == null) {
                onCanceled?.call();
              } else {
                onSelected?.call(value);
              }
            },
    );
  }
}

/// Line separating groups of actions.
class LumenMenuDivider<T> extends LumenMenuEntry<T> {
  /// Creates a divider.
  const LumenMenuDivider();
}

/// Entry in a neon menu: [LumenMenuItem] or [LumenMenuDivider].
sealed class LumenMenuEntry<T> {
  const LumenMenuEntry();
}

/// Action in a neon menu.
class LumenMenuItem<T> extends LumenMenuEntry<T> {
  /// Creates an action that returns [value] when selected.
  const LumenMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
    this.destructive = false,
  });

  /// Value returned by [showLumenMenu] / `onSelected`.
  final T value;

  /// Action text.
  final String label;

  /// Optional icon before [label].
  final IconData? icon;

  /// If `false`, the action appears dimmed and cannot be selected.
  final bool enabled;

  /// Colors the action with `palette.danger` (e.g. "Delete").
  final bool destructive;
}

class _LumenMenuRow<T> extends StatelessWidget {
  const _LumenMenuRow({
    required this.item,
    required this.color,
    required this.iconColor,
    required this.selected,
    required this.selectedColor,
    required this.style,
  });

  final LumenMenuItem<T> item;
  final Color color;
  final Color iconColor;
  final bool selected;
  final Color selectedColor;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final Color fg = selected ? selectedColor : color;
    final Widget row = Row(
      spacing: 12,
      children: <Widget>[
        if (item.icon != null) Icon(item.icon, size: 18, color: iconColor),
        Expanded(
          child: Text(
            item.label,
            overflow: TextOverflow.ellipsis,
            style: style?.copyWith(
              color: fg,
              fontWeight: selected ? FontWeight.w600 : null,
            ),
          ),
        ),
        if (selected) Icon(Icons.check_rounded, size: 18, color: fg),
      ],
    );
    return item.enabled
        ? row
        : Opacity(opacity: kLumenDisabledOpacity, child: row);
  }
}
