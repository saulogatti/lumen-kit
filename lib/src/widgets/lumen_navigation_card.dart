import 'package:lumen_kit/src/foundation/lumen_decorations.dart';
import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Reusable main screen navigation card.
///
/// You get what to show and what to do when playing — you don't decide anything
/// for yourself.
class LumenNavigationCard extends StatefulWidget {
  /// Creates a navigation card with visual highlighting and hover.
  const LumenNavigationCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
    super.key,
    this.tag,
    this.actionLabel = 'ACESSAR MÓDULO',
  });

  /// Title of the module or target.
  final String title;

  /// Short description displayed below the title.
  final String subtitle;

  /// Icon used in the card's visual badge.
  final IconData icon;

  /// Card highlight color.
  final Color accent;

  /// Callback executed when touching the card.
  final VoidCallback onTap;

  /// Optional tag displayed in the top right corner.
  final String? tag;

  /// Call text at the footer of the card.
  final String actionLabel;

  @override
  State<LumenNavigationCard> createState() => _LumenNavigationCardState();
}

class _LumenNavigationCardState extends State<LumenNavigationCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final accent = widget.accent;
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);

    // Hover e foco de teclado levantam o card do mesmo jeito.
    void highlight(bool on) {
      if (_hovering != on) {
        setState(() => _hovering = on);
      }
    }

    return AnimatedContainer(
      duration: LumenMotion.duration(context, kLumenMediumDuration),
      curve: Curves.easeOut,
      transform: Matrix4.identity()
        ..translateByDouble(0, _hovering ? -4.0 : 0.0, 0, 1),
      decoration: BoxDecoration(
        borderRadius: style.radius(20),
        boxShadow: style.shadows(<BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: _hovering ? 0.35 : 0.12),
            blurRadius: _hovering ? 36 : 18,
            spreadRadius: _hovering ? 1 : 0,
            offset: const Offset(0, 12),
          ),
        ]),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: style.radius(20),
        child: InkWell(
          onTap: widget.onTap,
          onHover: highlight,
          onFocusChange: highlight,
          borderRadius: style.radius(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: style.radius(20),
              gradient: style.fill(
                LumenDecorations.diagonal(
                  p.surface.withValues(alpha: style.surfaceAlpha(0.95)),
                  p.backgroundMid.withValues(alpha: style.surfaceAlpha(0.85)),
                ),
              ),
              border: style.borderAll(
                color: accent.withValues(alpha: _hovering ? 0.7 : 0.35),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _IconBadge(icon: widget.icon, accent: accent),
                    const Spacer(),
                    if (widget.tag case final String tag)
                      _Tag(label: tag, accent: accent),
                  ],
                ),
                const SizedBox(height: 28),
                Text(widget.title, style: text.headlineMedium),
                const SizedBox(height: 10),
                Text(widget.subtitle, style: text.bodyMedium),
                const SizedBox(height: 24),
                Row(
                  spacing: 8,
                  children: <Widget>[
                    Text(
                      widget.actionLabel,
                      style: text.labelLarge?.copyWith(color: accent),
                    ),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: accent),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.accent});

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final style = LumenStyle.of(context);
    return Container(
      width: 56,
      height: 56,
      decoration: LumenDecorations.iconBox(style, accent: accent, radius: 14),
      child: Icon(icon, color: accent, size: 28),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final style = LumenStyle.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: style.radius(999),
        border: style.borderAll(color: accent.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: accent),
      ),
    );
  }
}
