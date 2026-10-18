import 'dart:async';

import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:lumen_kit/src/widgets/lumen_icon_button.dart';
import 'package:material_ui/material_ui.dart';

/// Position for [showLumenMenu] at a global point on the screen (e.g.:
/// `TapUpDetails.globalPosition` from a right click).
RelativeRect lumenMenuPositionAt(BuildContext context, Offset globalPosition) {
  final overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
  final local = overlay.globalToLocal(globalPosition);
  return RelativeRect.fromRect(local & Size.zero, Offset.zero & overlay.size);
}

/// Old name of [lumenMenuPositionAt].
@Deprecated('Use lumenMenuPositionAt')
RelativeRect neonMenuPositionAt(BuildContext context, Offset globalPosition) =>
    lumenMenuPositionAt(context, globalPosition);

/// Opens a floating menu with [items] and returns the chosen value, or `null`
/// if the menu is closed without a choice.
/// Without [position], the menu opens anchored just below the widget owner of
/// [context] (like the "⋮" on a card). To open at a point on the screen (e.g.:
/// right click), use [lumenMenuPositionAt].
Future<T?> showLumenMenu<T>({
  required BuildContext context,
  required List<LumenMenuEntry<T>> items,
  RelativeRect? position,
  Color? accentColor,
  T? initialValue,
}) {
  assert(items.isNotEmpty, 'O menu precisa de ao menos uma entrada.');
  final p = LumenThemeExt.of(context).palette;
  final s = LumenStyle.of(context);
  final accent = accentColor ?? p.primary;
  final text = Theme.of(context).textTheme.bodyMedium;
  final border = s.borderAll(color: accent.withValues(alpha: 0.45), width: 1.2);

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
    popUpAnimationStyle: LumenMotion.reduced(context) ? AnimationStyle.noAnimation : null,
    items: <PopupMenuEntry<T>>[
      for (final LumenMenuEntry<T> entry in items)
        switch (entry) {
          LumenMenuDivider<T>() => PopupMenuDivider(height: 9, color: p.surfaceOutline),
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
  final overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
  final topLeft = box.localToGlobal(Offset(0, box.size.height), ancestor: overlay);
  final bottomRight = box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay);
  return RelativeRect.fromRect(Rect.fromPoints(topLeft, bottomRight), Offset.zero & overlay.size);
}

/// Open a context menu with right click (desktop/web) or long press (mobile) on
/// [child], in the pointer position.
/// It uses `GestureDetector` because it needs the position of the pointer,
/// which the `LumenPressable` does not expose; Screen readers open the menu by
/// swiping long press.
class LumenContextMenu<T> extends StatelessWidget {
  /// Menu actions.
  final List<LumenMenuEntry<T>> items;

  /// Called with the value of the chosen action.
  ///
  /// `null` turns off the menu.
  final ValueChanged<T>? onSelected;

  /// Content that receives the gesture.
  final Widget child;

  /// Accent override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Creates the context menu region.
  const LumenContextMenu({
    required this.items,
    required this.onSelected,
    required this.child,
    super.key,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (onSelected == null) {
      return child;
    }
    return Semantics(
      onLongPress: () {
        final box = context.findRenderObject()! as RenderBox;
        unawaited(_open(context, box.localToGlobal(box.size.center(Offset.zero))));
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onSecondaryTapUp: (d) => _open(context, d.globalPosition),
        onLongPressStart: (d) => _open(context, d.globalPosition),
        child: child,
      ),
    );
  }

  Future<void> _open(BuildContext context, Offset global) async {
    final value = await showLumenMenu<T>(
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
///
/// For cards, list tiles and app bars.
/// ```dart
/// LumenMenuButton<String>(
///   items: const <LumenMenuEntry<String>>[
///     LumenMenuItem(value: 'edit', label: 'Editar', icon: Icons.edit),
///     LumenMenuDivider(),
///     LumenMenuItem(value: 'del', label: 'Excluir', destructive: true),
///   ],
///   onSelected: handle,
/// )
/// ```
class LumenMenuButton<T> extends StatelessWidget {
  /// Menu actions.
  final List<LumenMenuEntry<T>> items;

  /// Called with the value of the chosen action.
  final ValueChanged<T>? onSelected;

  /// Called when the menu closes without a choice.
  final VoidCallback? onCanceled;

  /// Button icon.
  final IconData icon;

  /// Button tooltip.
  ///
  /// Default: Material "show menu" label.
  final String? tooltip;

  /// Accent override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Value marked with a check in the menu.
  final T? initialValue;

  /// Visual variant of the button.
  final LumenIconButtonVariant variant;

  /// Button side.
  final double size;

  /// Creates the menu button.
  ///
  /// With [onSelected] `null` is disabled.
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
              final value = await showLumenMenu<T>(
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
  /// Creates a separator.
  const LumenMenuDivider();
}

/// Entering a neon menu: [LumenMenuItem] or [LumenMenuDivider].
sealed class LumenMenuEntry<T> {
  const LumenMenuEntry();
}

/// Action of a neon menu.
class LumenMenuItem<T> extends LumenMenuEntry<T> {
  /// Amount returned by [showLumenMenu] / `onSelected`.
  final T value;

  /// Action text.
  final String label;

  /// Optional icon before [label].
  final IconData? icon;

  /// If `false`, the action appears dimmed and cannot be chosen.
  final bool enabled;

  /// Color the action with `palette.danger` (e.g.: "Delete").
  final bool destructive;

  /// Creates an action with [value] returned when chosen.
  const LumenMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
    this.destructive = false,
  });
}

class _LumenMenuRow<T> extends StatelessWidget {
  final LumenMenuItem<T> item;

  final Color color;
  final Color iconColor;
  final bool selected;
  final Color selectedColor;
  final TextStyle? style;
  const _LumenMenuRow({
    required this.item,
    required this.color,
    required this.iconColor,
    required this.selected,
    required this.selectedColor,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? selectedColor : color;
    final Widget row = Row(
      spacing: 12,
      children: <Widget>[
        if (item.icon != null) Icon(item.icon, size: 18, color: iconColor),
        Expanded(
          child: Text(
            item.label,
            overflow: TextOverflow.ellipsis,
            style: style?.copyWith(color: fg, fontWeight: selected ? FontWeight.w600 : null),
          ),
        ),
        if (selected) Icon(Icons.check_rounded, size: 18, color: fg),
      ],
    );
    return item.enabled ? row : Opacity(opacity: kLumenDisabledOpacity, child: row);
  }
}
