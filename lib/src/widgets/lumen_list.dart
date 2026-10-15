import 'package:material_ui/material_ui.dart';

/// Lazy list for many items. Its body is a [ListView.builder]: only visible
/// items are built.
///
/// When [itemCount] is `0`, displays [empty] (or nothing if [empty] is `null`).
/// The parent provides the height. Do not use `shrinkWrap` here: for a long
/// list, it builds all children and defeats the builder.
///
/// ```dart
/// LumenList(
///   itemCount: eventos.length,
///   empty: const LumenEmptyState(title: 'No events'),
///   itemBuilder: (BuildContext context, int i) => LumenListTile(
///     title: eventos[i].titulo,
///     onTap: () => abrir(eventos[i]),
///   ),
/// )
/// ```
class LumenList extends StatelessWidget {
  /// Creates the list. [itemBuilder] is called only for visible indices.
  const LumenList({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.separatorBuilder,
    this.controller,
    this.empty,
    this.padding,
  });

  /// Number of items. `0` displays [empty].
  final int itemCount;

  /// Builds the item at [index]. Usually a `LumenListTile`.
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Widget between two items. Without it, items sit directly together.
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Optional scroll controller.
  final ScrollController? controller;

  /// Content when [itemCount] is `0`.
  final Widget? empty;

  /// List padding.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return empty ?? const SizedBox.shrink();
    }
    if (separatorBuilder != null) {
      return ListView.separated(
        controller: controller,
        padding: padding,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        separatorBuilder: separatorBuilder!,
      );
    }
    return ListView.builder(
      controller: controller,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
