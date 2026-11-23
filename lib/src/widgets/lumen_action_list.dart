import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/widgets/lumen_card.dart';
import 'package:lumen_kit/src/widgets/lumen_icon_button.dart';
import 'package:material_ui/material_ui.dart';

/// An icon action displayed by a [LumenActionListItem].
class LumenListAction {
  /// Creates an action with a tooltip and an accessible label.
  const LumenListAction({
    required this.icon,
    required this.label,
    this.onPressed,
    this.accentColor,
  });

  /// Icon displayed on the button.
  final IconData icon;

  /// Tooltip and screen reader label describing what the action does.
  final String label;

  /// Callback executed when the action is activated. Defaults to `null`, which
  /// disables the button.
  final VoidCallback? onPressed;

  /// Button accent override. Defaults to the active palette's primary color.
  final Color? accentColor;
}

/// A scrollable list of items with an optional leading icon and up to two actions.
///
/// Rows are built on demand as the user scrolls. Give the list bounded width
/// and height, for example with a [SizedBox] or with [Expanded] in a [Column].
/// An empty list takes up no space when its parent allows it.
///
/// ```dart
/// SizedBox(
///   height: 200,
///   child: LumenActionList(
///     items: <LumenActionListItem>[
///       LumenActionListItem(
///         title: 'Project brief',
///         icon: Icons.description_outlined,
///         primaryAction: LumenListAction(
///           icon: Icons.edit_outlined,
///           label: 'Edit project brief',
///           onPressed: editBrief,
///         ),
///       ),
///       const LumenActionListItem(title: 'Meeting notes'),
///     ],
///   ),
/// )
/// ```
class LumenActionList extends StatelessWidget {
  /// Creates a list that renders [items] in order.
  const LumenActionList({
    required this.items,
    super.key,
    bool? primary,
    EdgeInsetsGeometry? padding,
    double? spacing,
  }) : primary = primary ?? false,
       padding = padding ?? EdgeInsets.zero,
       spacing = spacing ?? 8;

  /// Rows to display, in display order.
  final List<LumenActionListItem> items;

  /// Whether to use the nearest [PrimaryScrollController]. Defaults to `false`.
  final bool primary;

  /// Padding around the list's contents. Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry padding;

  /// Vertical space between rows, in logical pixels. Defaults to `8`.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    late final indexesByKey = <Key, int>{
      for (var index = 0; index < items.length; index++)
        if (items[index].key case final Key key) key: index,
    };

    return ListView.separated(
      primary: primary,
      padding: padding,
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      findItemIndexCallback: (key) => indexesByKey[key],
    );
  }
}

/// A row for [LumenActionList] with its own title, optional icon and actions.
///
/// The icon and actions follow the reading direction. In narrow layouts, the
/// actions move below the text. Each button is independently focusable.
class LumenActionListItem extends StatelessWidget {
  /// Creates a list row with zero, one or two actions.
  const LumenActionListItem({
    required this.title,
    super.key,
    this.subtitle,
    this.icon,
    this.primaryAction,
    this.secondaryAction,
  });

  /// Main text of the row.
  final String title;

  /// Secondary text displayed below [title].
  final String? subtitle;

  /// Decorative icon displayed before the text.
  final IconData? icon;

  /// First optional action in reading order.
  final LumenListAction? primaryAction;

  /// Second optional action in reading order.
  final LumenListAction? secondaryAction;

  static const double _actionSize = 48;
  static const double _actionSpacing = 4;
  static const double _contentSpacing = 8;
  static const double _iconSize = 20;
  static const double _iconSpacing = 12;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final textTheme = Theme.of(context).textTheme;
    final content = Row(
      spacing: _iconSpacing,
      children: <Widget>[
        if (icon case final IconData icon) Icon(icon, color: p.primary, size: _iconSize),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: <Widget>[
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(color: p.textPrimary, fontWeight: .w600),
              ),
              if (subtitle case final String subtitle)
                Text(subtitle, style: textTheme.bodySmall?.copyWith(color: p.textMuted)),
            ],
          ),
        ),
      ],
    );

    final actions = <LumenListAction>[?primaryAction, ?secondaryAction];
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: LumenCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        borderRadius: 14,
        borderOpacity: 0.2,
        child: actions.isEmpty
            ? content
            : LayoutBuilder(
                builder: (context, constraints) {
                  final actionsWidth =
                      actions.length * _actionSize + (actions.length - 1) * _actionSpacing;
                  final iconWidth = icon == null ? 0 : _iconSize + _iconSpacing;
                  const minTextWidth = 120;
                  final stack =
                      constraints.maxWidth <
                      minTextWidth + iconWidth + _contentSpacing + actionsWidth;

                  return Flex(
                    direction: stack ? Axis.vertical : Axis.horizontal,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: stack ? CrossAxisAlignment.end : CrossAxisAlignment.center,
                    spacing: _contentSpacing,
                    children: <Widget>[
                      Flexible(flex: stack ? 0 : 1, child: content),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: _actionSpacing,
                        runSpacing: _actionSpacing,
                        children: <Widget>[
                          for (final action in actions)
                            Tooltip(
                              message: action.label,
                              excludeFromSemantics: true,
                              child: LumenIconButton.ghost(
                                icon: action.icon,
                                onPressed: action.onPressed,
                                semanticLabel: action.label,
                                accentColor: action.accentColor,
                                size: _actionSize,
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
