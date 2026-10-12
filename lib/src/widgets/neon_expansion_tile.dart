import 'package:material_ui/material_ui.dart';

import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Tile expansível com header em surface, ícone com rotação animada e borda
/// accent quando aberto.
class NeonExpansionTile extends StatefulWidget {
  /// Cria um tile expansível com [children] revelados ao abrir.
  const NeonExpansionTile({
    required this.title,
    required this.children,
    super.key,
    this.subtitle,
    this.leading,
    this.initiallyExpanded = false,
    this.accentColor,
    this.onExpansionChanged,
  });

  /// Título exibido no cabeçalho.
  final String title;

  /// Texto auxiliar exibido abaixo de [title].
  final String? subtitle;

  /// Widget opcional exibido antes do texto.
  final Widget? leading;

  /// Conteúdo exibido quando o tile está expandido.
  final List<Widget> children;

  /// Se `true`, inicia o tile expandido.
  final bool initiallyExpanded;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  /// Callback chamado sempre que o estado expandido muda.
  final ValueChanged<bool>? onExpansionChanged;

  @override
  State<NeonExpansionTile> createState() => _NeonExpansionTileState();
}

class _NeonExpansionTileState extends State<NeonExpansionTile>
    with SingleTickerProviderStateMixin {
  late bool _expanded = widget.initiallyExpanded;
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: _expanded ? 1 : 0,
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
    widget.onExpansionChanged?.call(_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Color accent = widget.accentColor ?? p.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        borderRadius: style.radius(14),
        color: p.surface.withValues(alpha: style.surfaceAlpha(0.55)),
        border: style.borderAll(
          color: _expanded
              ? accent.withValues(alpha: 0.6)
              : p.surfaceOutline.withValues(alpha: 0.45),
        ),
        boxShadow: style.shadows(
          _expanded
              ? <BoxShadow>[
                  BoxShadow(
                    color: accent.withValues(alpha: 0.2),
                    blurRadius: 14,
                    spreadRadius: -3,
                  ),
                ]
              : null,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InkWell(
            onTap: _toggle,
            borderRadius: style.radius(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: <Widget>[
                  if (widget.leading != null) ...<Widget>[
                    widget.leading!,
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: p.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (widget.subtitle != null) ...<Widget>[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!,
                            style: TextStyle(color: p.textMuted, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                  RotationTransition(
                    turns: Tween<double>(begin: 0, end: 0.5).animate(_ctrl),
                    child: Icon(Icons.expand_more_rounded, color: accent),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
