import 'package:material_ui/material_ui.dart';

import 'lumen_tokens.dart';

/// Tappable foundation of the kit: applies disabled opacity, a ripple clipped
/// to [borderRadius], keyboard focus, and button semantics.
///
/// Use it to build custom components with the same behavior as the kit's
/// buttons:
///
/// ```dart
/// LumenPressable(
///   onTap: save,
///   borderRadius: LumenStyle.of(context).radius(14),
///   child: myDecoratedBox,
/// )
/// ```
class LumenPressable extends StatelessWidget {
  /// Creates a tappable area. Disabled when [onTap] and [onLongPress] are `null`
  /// or [enabled] is `false`.
  const LumenPressable({
    required this.child,
    super.key,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.borderRadius,
    this.customBorder,
    this.dimWhenDisabled = true,
    this.semanticLabel,
    this.button = true,
    this.selected,
    this.checked,
    this.toggled,
    this.mergeSemantics = true,
  });

  /// Visual content.
  final Widget child;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Long-press callback.
  final VoidCallback? onLongPress;

  /// Forces the disabled state even when callbacks are present (e.g. `busy`).
  final bool enabled;

  /// Radius used to clip the ripple and [Material].
  final BorderRadius? borderRadius;

  /// Shape alternative to [borderRadius] (e.g. [CircleBorder]).
  final ShapeBorder? customBorder;

  /// If `true`, applies [kLumenDisabledOpacity] when disabled.
  final bool dimWhenDisabled;

  /// Accessibility label, combined with the children's text. Use when the
  /// content has no text (e.g. an icon only).
  final String? semanticLabel;

  /// Announces the widget as a button to screen readers.
  final bool button;

  /// Announced selected state (tabs, navigation items).
  final bool? selected;

  /// Announced checked state (checkbox, radio).
  final bool? checked;

  /// Announced toggled state (switch).
  final bool? toggled;

  /// Combines the children's text into one node (as `ListTile` does), so a
  /// screen reader says "Accepted, checked" instead of reading two items.
  /// Disable when the child contains other controls (e.g. a card with buttons).
  final bool mergeSemantics;

  /// Whether the widget responds to taps with the current properties.
  bool get isEnabled => enabled && (onTap != null || onLongPress != null);

  @override
  Widget build(BuildContext context) {
    final bool active = isEnabled;
    final Widget ink = Material(
      type: MaterialType.transparency,
      borderRadius: customBorder == null ? borderRadius : null,
      shape: customBorder,
      child: InkWell(
        onTap: active ? onTap : null,
        onLongPress: active ? onLongPress : null,
        borderRadius: borderRadius,
        customBorder: customBorder,
        // Semantics below provides this semantics; avoid a duplicate node.
        excludeFromSemantics: true,
        child: child,
      ),
    );

    final Widget semantics = Semantics(
      container: true,
      button: button && checked == null && toggled == null ? true : null,
      enabled: active,
      selected: selected,
      checked: checked,
      toggled: toggled,
      label: semanticLabel,
      onTap: active ? onTap : null,
      onLongPress: active ? onLongPress : null,
      child: dimWhenDisabled && !active
          ? Opacity(opacity: kLumenDisabledOpacity, child: ink)
          : ink,
    );
    return mergeSemantics ? MergeSemantics(child: semantics) : semantics;
  }
}
