import 'package:material_ui/material_ui.dart';

/// Sliver counterpart of `LumenList`, for a [CustomScrollView] shared with a
/// `LumenSliverAppBar` or other slivers.
///
/// Builds items on demand. When [itemCount] is zero, it displays [empty] if
/// provided. Scrolling options belong to the surrounding [CustomScrollView].
///
/// ```dart
/// CustomScrollView(
///   slivers: <Widget>[
///     const LumenSliverAppBar(title: 'Events'),
///     LumenSliverList(
///       padding: const EdgeInsets.all(16),
///       itemCount: events.length,
///       separatorBuilder: (BuildContext context, int i) =>
///           const SizedBox(height: 8),
///       itemBuilder: (BuildContext context, int i) =>
///           LumenListTile(title: events[i].title),
///     ),
///   ],
/// )
/// ```
class LumenSliverList extends StatelessWidget {
  /// Quantity of items.
  ///
  /// `0` shows [empty].
  final int itemCount;

  /// The callback that builds the item at the requested index.
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Widget between two items.
  ///
  /// Without it, items stick together.
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Content when [itemCount] is `0`, laid out as a regular box.
  final Widget? empty;

  /// Space around the items, or around [empty].
  final EdgeInsetsGeometry? padding;

  /// If true, the list will add automatic keep alive.
  final bool addAutomaticKeepAlives;

  /// If true, the list will add repaint boundaries.
  final bool addRepaintBoundaries;

  /// If true, the list will add semantic indexes.
  final bool addSemanticIndexes;

  /// Creates a sliver list that builds items on demand.
  const LumenSliverList({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.separatorBuilder,
    this.empty,
    this.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
  });

  @override
  Widget build(BuildContext context) {
    final Widget sliver;
    if (itemCount == 0) {
      sliver = SliverToBoxAdapter(child: empty);
    } else if (separatorBuilder case final separatorBuilder?) {
      sliver = SliverList.separated(
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        separatorBuilder: separatorBuilder,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
      );
    } else {
      sliver = SliverList.builder(
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
