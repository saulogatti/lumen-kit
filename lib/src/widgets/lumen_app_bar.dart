import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// AppBar with neon identity: transparent, with bottom gradient line and
/// typography consistent with the theme.
class LumenAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Main title displayed in the app bar.
  final String title;

  /// Auxiliary text displayed below [title].
  final String? subtitle;

  /// Widget displayed before the title.
  final Widget? leading;

  /// Actions displayed on the right side.
  final List<Widget>? actions;

  /// Bottom decorative line gradient.
  ///
  /// Default: `palette.accentGradient`.
  final Gradient? accentGradient;

  /// Height of the app bar content area.
  final double height;

  /// Whether to display the bottom decorative line.
  final bool showDivider;

  /// Create a neon bar app compatible with [Scaffold.appBar].
  const LumenAppBar({
    required this.title,
    super.key,
    this.subtitle,
    this.leading,
    this.actions,
    this.accentGradient,
    this.height = 64,
    this.showDivider = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(height + (showDivider ? 2 : 0));

  @override
  Widget build(BuildContext context) {
    final style = LumenStyle.of(context);
    final text = Theme.of(context).textTheme;
    final g = accentGradient ?? LumenThemeExt.of(context).palette.accentGradient;

    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  if (leading != null) ...<Widget>[leading!, const SizedBox(width: 12)],
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(title, style: text.titleLarge),
                        if (subtitle != null) ...<Widget>[
                          const SizedBox(height: 2),
                          Text(subtitle!, style: text.bodySmall),
                        ],
                      ],
                    ),
                  ),
                  if (actions != null) Row(mainAxisSize: MainAxisSize.min, children: actions!),
                ],
              ),
            ),
          ),
          if (showDivider) Container(height: 2, decoration: BoxDecoration(gradient: style.fill(g))),
        ],
      ),
    );
  }
}
