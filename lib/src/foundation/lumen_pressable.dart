import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Touchable Kit Base: Applies Disabled Opacity, Cropped Ripple in
/// [borderRadius], keyboard focus and button semantics.
/// Use to build your own components with the same behavior as kit buttons:
/// ```dart
/// LumenPressable(
///   onTap: save,
///   borderRadius: LumenStyle.of(context).radius(14),
///   child: myDecoratedBox,
/// )
/// ```
class LumenPressable extends StatelessWidget {
  /// Creates a touchable area.
  ///
  /// It is disabled when [onTap] and [onLongPress] are `null` or [enabled] is
  /// `false`.
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

  /// Ring callback.
  final VoidCallback? onTap;

  /// Long press callback.
  final VoidCallback? onLongPress;

  /// Forces the disabled state even with callbacks present (e.g.: `busy`).
  final bool enabled;

  /// Radius used to cut ripple and [Material].
  final BorderRadius? borderRadius;

  /// Alternative form to [borderRadius] (e.g.: [CircleBorder]).
  final ShapeBorder? customBorder;

  /// Whether to apply [kLumenDisabledOpacity] when disabled.
  final bool dimWhenDisabled;

  /// Accessibility label, added to the children's text.
  ///
  /// Use when the content has no text (e.g. only icon).
  final String? semanticLabel;

  /// Announces the widget as a button for screen readers.
  final bool button;

  /// Advertised selection state (tabs, navigation items).
  final bool? selected;

  /// State marked announced (checkbox, radio).
  final bool? checked;

  /// Announced on state (switch).
  final bool? toggled;

  /// Joins the children's texts into a single node (like `ListTile` does), for
  /// the screen reader read "Accepted, checked" instead of two items.
  ///
  /// Hang up when the child has other controls inside (e.g. card with buttons).
  final bool mergeSemantics;

  /// Whether the widget responds to touch with the current props.
  bool get isEnabled => enabled && (onTap != null || onLongPress != null);

  @override
  Widget build(BuildContext context) {
    final active = isEnabled;
    final Widget ink = Material(
      type: MaterialType.transparency,
      borderRadius: customBorder == null ? borderRadius : null,
      shape: customBorder,
      child: InkWell(
        onTap: active ? onTap : null,
        onLongPress: active ? onLongPress : null,
        borderRadius: borderRadius,
        customBorder: customBorder,
        // A semântica vem do Semantics abaixo; evita nó duplicado.
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
