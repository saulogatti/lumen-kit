import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

/// A scrollable grid that builds cells on demand.
///
/// The default constructor uses a fixed number of columns. [LumenGrid.extent]
/// fits as many columns as the width allows, each at most
/// [maxCrossAxisExtent] wide. When [itemCount] is zero, it displays [empty] if
/// provided.
///
/// For long grids, prefer a bounded viewport along [scrollDirection] with
/// [shrinkWrap] disabled.
///
/// ```dart
/// LumenGrid.extent(
///   maxCrossAxisExtent: 160,
///   itemCount: modules.length,
///   empty: const LumenEmptyState(title: 'No modules'),
///   itemBuilder: (BuildContext context, int i) => LumenGridTile(
///     title: modules[i].name,
///     leading: Icon(modules[i].icon),
///     onTap: () => open(modules[i]),
///   ),
/// )
/// ```
class LumenGrid extends StatelessWidget {
  /// Quantity of cells.
  ///
  /// `0` shows [empty].
  final int itemCount;

  /// The callback that builds the cell at the requested index.
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Number of cells along the cross axis.
  ///
  /// Set by the default constructor; `null` in [LumenGrid.extent].
  final int? crossAxisCount;

  /// Largest size of a cell along the cross axis.
  ///
  /// Set by [LumenGrid.extent]; `null` in the default constructor.
  final double? maxCrossAxisExtent;

  /// Space between cells along [scrollDirection].
  final double mainAxisSpacing;

  /// Space between cells across [scrollDirection].
  final double crossAxisSpacing;

  /// Ratio of the cross-axis size to the main-axis size of each cell.
  ///
  /// Ignored when [mainAxisExtent] is set.
  final double childAspectRatio;

  /// Fixed size of each cell along [scrollDirection].
  ///
  /// Without it, the size comes from [childAspectRatio].
  final double? mainAxisExtent;

  /// Optional scroll controller.
  final ScrollController? controller;

  /// Content when [itemCount] is `0`.
  final Widget? empty;

  /// Internal grid space.
  final EdgeInsetsGeometry? padding;

  /// Whether the grid sizes itself to its contents along [scrollDirection].
  ///
  /// Unbounded constraints along that axis require shrink wrapping, which can
  /// be more expensive because the scroll view may have to recompute its size
  /// during scrolling.
  final bool shrinkWrap;

  /// The physics of the grid.
  final ScrollPhysics? physics;

  /// If true, the grid will add automatic keep alive.
  final bool addAutomaticKeepAlives;

  /// If true, the grid will add repaint boundaries.
  final bool addRepaintBoundaries;

  /// If true, the grid will add semantic indexes.
  final bool addSemanticIndexes;

  /// The clip behavior of the grid.
  final Clip clipBehavior;

  /// The drag start behavior of the grid.
  final DragStartBehavior dragStartBehavior;

  /// The keyboard dismiss behavior of the grid.
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// If true, the grid will be reversed.
  final bool reverse;

  /// The scroll direction of the grid.
  final Axis scrollDirection;

  /// Creates a grid with [crossAxisCount] columns that builds cells on demand.
  const LumenGrid({
    required this.itemCount,
    required this.itemBuilder,
    required int this.crossAxisCount,
    super.key,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
    this.childAspectRatio = 1,
    this.mainAxisExtent,
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
  }) : maxCrossAxisExtent = null,
       assert(crossAxisCount > 0, 'crossAxisCount must be greater than zero.');

  /// Creates a grid whose cells are at most [maxCrossAxisExtent] wide.
  ///
  /// The number of columns follows the available width, so the same grid
  /// adapts from phone to desktop.
  const LumenGrid.extent({
    required this.itemCount,
    required this.itemBuilder,
    required double this.maxCrossAxisExtent,
    super.key,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
    this.childAspectRatio = 1,
    this.mainAxisExtent,
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
  }) : crossAxisCount = null,
       assert(maxCrossAxisExtent > 0, 'maxCrossAxisExtent must be greater than zero.');

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return empty ?? const SizedBox.shrink();
    }
    final gridDelegate = switch (crossAxisCount) {
      final int count => SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
        mainAxisExtent: mainAxisExtent,
      ),
      null => SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent!,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
        mainAxisExtent: mainAxisExtent,
      ),
    };
    return GridView.builder(
      gridDelegate: gridDelegate,
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
