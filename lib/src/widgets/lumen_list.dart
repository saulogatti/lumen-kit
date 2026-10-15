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
  });

  /// Quantity of items.
  ///
  /// `0` shows [empty].
  final int itemCount;

  /// Builds the item in [index].
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
