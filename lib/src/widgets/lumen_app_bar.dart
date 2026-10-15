import 'package:material_ui/material_ui.dart';

import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// AppBar with a neon identity: transparent, with a bottom gradient line and
/// typography consistent with the theme.
class LumenAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a neon app bar compatible with [Scaffold.appBar].
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

  /// Main title displayed in the app bar.
  final String title;

  /// Supporting text displayed below [title].
  final String? subtitle;

  /// Widget displayed before the title.
  final Widget? leading;

  /// Actions displayed on the right.
  final List<Widget>? actions;

  /// Gradient for the decorative bottom line. Default: `palette.accentGradient`.
  final Gradient? accentGradient;

  /// Height of the app bar's content area.
  final double height;

  /// If `true`, displays the decorative bottom line.
  final bool showDivider;

  @override
  Size get preferredSize => Size.fromHeight(height + (showDivider ? 2 : 0));

  @override
  Widget build(BuildContext context) {
    final LumenStyle style = LumenStyle.of(context);
    final TextTheme text = Theme.of(context).textTheme;
    final Gradient g =
        accentGradient ?? LumenThemeExt.of(context).palette.accentGradient;

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
                  if (leading != null) ...<Widget>[
                    leading!,
                    const SizedBox(width: 12),
                  ],
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
                  if (actions != null)
                    Row(mainAxisSize: MainAxisSize.min, children: actions!),
                ],
              ),
            ),
          ),
          if (showDivider)
            Container(
              height: 2,
              decoration: BoxDecoration(gradient: style.fill(g)),
            ),
        ],
      ),
    );
  }
}
