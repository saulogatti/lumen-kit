import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// AppBar com identidade neon: transparente, com linha de gradiente inferior
/// e tipografia consistente com o tema.
class NeonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NeonAppBar({
    required this.title,
    super.key,
    this.subtitle,
    this.leading,
    this.actions,
    this.accentGradient,
    this.height = 64,
    this.showDivider = true,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;

  /// Gradiente da linha decorativa inferior. Default: [AppColors.accentGradient].
  final Gradient? accentGradient;

  final double height;
  final bool showDivider;

  @override
  Size get preferredSize => Size.fromHeight(height + (showDivider ? 2 : 0));

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Gradient g = accentGradient ?? AppColors.accentGradient;

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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions!,
                    ),
                ],
              ),
            ),
          ),
          if (showDivider)
            Container(
              height: 2,
              decoration: BoxDecoration(gradient: g),
            ),
        ],
      ),
    );
  }
}
