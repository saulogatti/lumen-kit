import 'package:material_ui/material_ui.dart';

import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Card de navegação reutilizável da tela principal.
/// Recebe o que mostrar e o que fazer ao tocar — não decide nada por si.
class NavigationCard extends StatefulWidget {
  /// Cria um card de navegação com destaque visual e hover.
  const NavigationCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
    super.key,
    this.tag,
  });

  /// Título do módulo ou destino.
  final String title;

  /// Descrição curta exibida abaixo do título.
  final String subtitle;

  /// Ícone usado no badge visual do card.
  final IconData icon;

  /// Cor de destaque do card.
  final Color accent;

  /// Callback executado ao tocar no card.
  final VoidCallback onTap;

  /// Tag opcional exibida no canto superior direito.
  final String? tag;

  @override
  State<NavigationCard> createState() => _NavigationCardState();
}

class _NavigationCardState extends State<NavigationCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Color accent = widget.accent;
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translateByDouble(0.0, _hovering ? -4.0 : 0.0, 0.0, 1.0),
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
            borderRadius: style.radius(20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: style.radius(20),
                gradient: style.fill(
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      p.surface.withValues(alpha: style.surfaceAlpha(0.95)),
                      p.backgroundMid.withValues(
                        alpha: style.surfaceAlpha(0.85),
                      ),
                    ],
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
                      if (widget.tag != null)
                        _Tag(label: widget.tag!, accent: accent),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(widget.title, style: text.headlineMedium),
                  const SizedBox(height: 10),
                  Text(widget.subtitle, style: text.bodyMedium),
                  const SizedBox(height: 24),
                  Row(
                    children: <Widget>[
                      Text(
                        'ACESSAR MÓDULO',
                        style: text.labelLarge?.copyWith(color: accent),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: accent,
                      ),
                    ],
                  ),
                ],
              ),
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
    final NeonStyle style = NeonStyle.of(context);
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: style.radius(14),
        color: accent.withValues(alpha: 0.12),
        border: style.borderAll(color: accent.withValues(alpha: 0.45)),
      ),
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
    final NeonStyle style = NeonStyle.of(context);
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
