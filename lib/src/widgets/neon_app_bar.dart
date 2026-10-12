import 'package:material_ui/material_ui.dart';

import '../theme/neon_palette.dart';

/// AppBar com identidade neon: transparente, com linha de gradiente inferior
/// e tipografia consistente com o tema.
class NeonAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Cria uma app bar neon compatível com [Scaffold.appBar].
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

  /// Título principal exibido na app bar.
  final String title;

  /// Texto auxiliar exibido abaixo de [title].
  final String? subtitle;

  /// Widget exibido antes do título.
  final Widget? leading;

  /// Ações exibidas no lado direito.
  final List<Widget>? actions;

  /// Gradiente da linha decorativa inferior. Default: `palette.accentGradient`.
  final Gradient? accentGradient;

  /// Altura da área de conteúdo da app bar.
  final double height;

  /// Se `true`, exibe a linha decorativa inferior.
  final bool showDivider;

  @override
  Size get preferredSize => Size.fromHeight(height + (showDivider ? 2 : 0));

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Gradient g =
        accentGradient ?? NeonThemeExt.of(context).palette.accentGradient;

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
            Container(height: 2, decoration: BoxDecoration(gradient: g)),
        ],
      ),
    );
  }
}
