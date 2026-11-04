import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

/// Lazy list for many items.
///
/// The body is a [ListView.builder]: only what is on the screen is constructed.
/// With [itemCount] `0`, it shows [empty] (or nothing, if [empty] is `null`).
/// The height comes from the father. Do not use `shrinkWrap` here: in a long
/// list this builds all children and cancels the builder.
/// ```dart
/// LumenList(
///   itemCount: eventos.length,
///   empty: const LumenEmptyState(title: 'Nenhum evento'),
///   itemBuilder: (BuildContext context, int i) => LumenListTile(
///     title: eventos[i].titulo,
///     onTap: () => abrir(eventos[i]),
///   ),
/// )
/// ```
class LumenList extends StatelessWidget {
  /// Quantity of items.
  ///
  /// `0` shows [empty].
  final int itemCount;

  /// Builds the item in ´index`.
  ///
  /// In general a `LumenListTile`.
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Widget between two items.
  ///
  /// Without it, items stick together.
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Optional scroll controller.
  final ScrollController? controller;

  /// Content when [itemCount] is `0`.
  final Widget? empty;

  /// Internal list space.
  final EdgeInsetsGeometry? padding;

  /// If true, the list will be shrinked to the size of the items.
  final bool shrinkWrap;

  /// The physics of the list.
  final ScrollPhysics? physics;

  /// If true, the list will add automatic keep alive.
  final bool addAutomaticKeepAlives;

  /// If true, the list will add repaint boundaries.
  final bool addRepaintBoundaries;

  /// If true, the list will add semantic indexes.
  final bool addSemanticIndexes;

  /// The clip behavior of the list.
  final Clip clipBehavior;

  /// The drag start behavior of the list.
  final DragStartBehavior dragStartBehavior;

  /// The keyboard dismiss behavior of the list.
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// If true, the list will be reversed.
  final bool reverse;

  /// The scroll direction of the list.
  final Axis scrollDirection;

  /// Create the list.
  ///
  /// [itemBuilder] is only called for visible indexes.
  const LumenList({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.separatorBuilder,
    this.controller,
    this.empty,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.clipBehavior = Clip.hardEdge,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return empty ?? const SizedBox.shrink();
    }
    if (separatorBuilder != null) {
      return ListView.separated(
        itemBuilder: itemBuilder,
        itemCount: itemCount,
        separatorBuilder: separatorBuilder!,
        shrinkWrap: shrinkWrap,
        physics: physics,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        clipBehavior: clipBehavior,
        dragStartBehavior: dragStartBehavior,
        keyboardDismissBehavior: keyboardDismissBehavior,
        reverse: reverse,
        scrollDirection: scrollDirection,
        controller: controller,
        padding: padding,
      );
    }
    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      clipBehavior: clipBehavior,
      dragStartBehavior: dragStartBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior,
      reverse: reverse,
      scrollDirection: scrollDirection,
      controller: controller,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
