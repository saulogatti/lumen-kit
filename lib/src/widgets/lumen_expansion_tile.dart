import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_tokens.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Expandable tile with a surface header, animated rotating icon, and accent
/// border when open.
class LumenExpansionTile extends StatefulWidget {
  /// Creates an expandable tile that reveals [children] when opened.
  const LumenExpansionTile({
    required this.title,
    required this.children,
    super.key,
    this.subtitle,
    this.leading,
    this.initiallyExpanded = false,
    this.accentColor,
    this.onExpansionChanged,
  });

  /// Title displayed in the header.
  final String title;

  /// Supporting text displayed below [title].
  final String? subtitle;

  /// Optional widget displayed before the text.
  final Widget? leading;

  /// Content displayed when the tile is expanded.
  final List<Widget> children;

  /// If `true`, starts with the tile expanded.
  final bool initiallyExpanded;

  /// Accent color override. Default: `palette.primary`.
  final Color? accentColor;

  /// Callback called whenever the expanded state changes.
  final ValueChanged<bool>? onExpansionChanged;

  @override
  State<LumenExpansionTile> createState() => _LumenExpansionTileState();
}

class _LumenExpansionTileState extends State<LumenExpansionTile>
    with SingleTickerProviderStateMixin {
  late bool _expanded = widget.initiallyExpanded;
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: kLumenMediumDuration,
    value: _expanded ? 1 : 0,
  );
  // Created once: creating these in build leaked a listener every frame.
  late final CurvedAnimation _size = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeOut,
  );
  late final Animation<double> _turns = _ctrl.drive(
    Tween<double>(begin: 0, end: 0.5),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ctrl.duration = LumenMotion.duration(context, kLumenMediumDuration);
  }

  @override
  void dispose() {
    _size.dispose();
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
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final Color accent = widget.accentColor ?? p.primary;

    return AnimatedContainer(
      duration: LumenMotion.duration(context, kLumenMediumDuration),
      decoration: BoxDecoration(
        borderRadius: style.radius(14),
        color: p.surface.withValues(alpha: style.surfaceAlpha(0.55)),
        border: style.borderAll(
          color: _expanded
              ? accent.withValues(alpha: 0.6)
              : p.surfaceOutline.outlineAlpha(0.45),
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
          Semantics(
            expanded: _expanded,
            child: InkWell(
              onTap: _toggle,
              borderRadius: style.radius(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  spacing: 12,
                  children: <Widget>[
                    ?widget.leading,
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
                          if (widget.subtitle case final String subtitle)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                subtitle,
                                style: TextStyle(
                                  color: p.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    RotationTransition(
                      turns: _turns,
                      child: Icon(Icons.expand_more_rounded, color: accent),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _size,
            // When closed, the content is also removed from focus and screen readers.
            child: ExcludeFocus(
              excluding: !_expanded,
              child: ExcludeSemantics(
                excluding: !_expanded,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: widget.children,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
