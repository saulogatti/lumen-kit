import 'package:material_ui/material_ui.dart';

/// Sliver counterpart of `LumenGrid`, for a [CustomScrollView] shared with a
/// `LumenSliverAppBar` or other slivers.
///
/// The default constructor uses a fixed number of columns.
/// [LumenSliverGrid.extent] fits as many columns as the width allows, each at
/// most [maxCrossAxisExtent] wide. When [itemCount] is zero, it displays
/// [empty] if provided. Scrolling options belong to the surrounding
/// [CustomScrollView].
///
/// ```dart
/// CustomScrollView(
///   slivers: <Widget>[
///     const LumenSliverAppBar(title: 'Modules'),
///     LumenSliverGrid.extent(
///       maxCrossAxisExtent: 160,
///       padding: const EdgeInsets.all(16),
///       itemCount: modules.length,
///       itemBuilder: (BuildContext context, int i) =>
///           LumenGridTile(title: modules[i].name),
///     ),
///   ],
/// )
/// ```
class LumenSliverGrid extends StatelessWidget {
  /// Quantity of cells.
  ///
  /// `0` shows [empty].
  final int itemCount;

  /// The callback that builds the cell at the requested index.
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Number of cells along the cross axis.
  ///
  /// Set by the default constructor; `null` in [LumenSliverGrid.extent].
  final int? crossAxisCount;

  /// Largest size of a cell along the cross axis.
  ///
  /// Set by [LumenSliverGrid.extent]; `null` in the default constructor.
  final double? maxCrossAxisExtent;

  /// Space between cells along the scroll direction.
  final double mainAxisSpacing;

  /// Space between cells across the scroll direction.
  final double crossAxisSpacing;

  /// Ratio of the cross-axis size to the main-axis size of each cell.
  ///
  /// Ignored when [mainAxisExtent] is set.
  final double childAspectRatio;

  /// Fixed size of each cell along the scroll direction.
  ///
  /// Without it, the size comes from [childAspectRatio].
  final double? mainAxisExtent;

  /// Content when [itemCount] is `0`, laid out as a regular box.
  final Widget? empty;

  /// Space around the cells, or around [empty].
  final EdgeInsetsGeometry? padding;

  /// If true, the grid will add automatic keep alive.
  final bool addAutomaticKeepAlives;

  /// If true, the grid will add repaint boundaries.
  final bool addRepaintBoundaries;

  /// If true, the grid will add semantic indexes.
  final bool addSemanticIndexes;

  /// Creates a sliver grid with [crossAxisCount] columns that builds cells on
  /// demand.
  const LumenSliverGrid({
    required this.itemCount,
    required this.itemBuilder,
    required int this.crossAxisCount,
    super.key,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
    this.childAspectRatio = 1,
    this.mainAxisExtent,
    this.empty,
    this.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
  }) : maxCrossAxisExtent = null,
       assert(crossAxisCount > 0, 'crossAxisCount must be greater than zero.');

  /// Creates a sliver grid whose cells are at most [maxCrossAxisExtent] wide.
  ///
  /// The number of columns follows the available width, so the same grid
  /// adapts from phone to desktop.
  const LumenSliverGrid.extent({
    required this.itemCount,
    required this.itemBuilder,
    required double this.maxCrossAxisExtent,
    super.key,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
    this.childAspectRatio = 1,
    this.mainAxisExtent,
    this.empty,
    this.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
  }) : crossAxisCount = null,
       assert(maxCrossAxisExtent > 0, 'maxCrossAxisExtent must be greater than zero.');

  @override
  Widget build(BuildContext context) {
    final Widget sliver;
    if (itemCount == 0) {
      sliver = SliverToBoxAdapter(child: empty);
    } else {
      sliver = SliverGrid.builder(
        gridDelegate: switch (crossAxisCount) {
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
        },
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
      );
    }
    return switch (padding) {
      final EdgeInsetsGeometry padding => SliverPadding(padding: padding, sliver: sliver),
      null => sliver,
    };
  }
}
