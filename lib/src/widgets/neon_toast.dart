import 'package:material_ui/material_ui.dart';

import '../theme/neon_palette.dart';
import 'status_chip.dart';

/// Posição vertical do toast na tela.
enum NeonToastPosition {
  /// Toast alinhado próximo ao topo, respeitando o padding seguro.
  top,

  /// Toast alinhado próximo à base, respeitando o padding seguro.
  bottom,
}

/// Exibe um toast flutuante sobre o app via `Overlay`, sem depender de
/// `ScaffoldMessenger`. Útil para feedbacks rápidos em telas sem `Scaffold`
/// (ex.: splash, onboarding).
///
/// Retorna um [Future] que completa quando o toast some.
///
/// [tone] define cor e ícone padrão, [position] escolhe o alinhamento vertical
/// e [margin] controla a distância horizontal e vertical das bordas seguras.
Future<void> showNeonToast({
  required BuildContext context,
  required String message,
  StatusTone tone = StatusTone.info,
  IconData? icon,
  Duration duration = const Duration(seconds: 3),
  NeonToastPosition position = NeonToastPosition.bottom,
  double margin = 24,
}) async {
  final OverlayState overlay = Overlay.of(context, rootOverlay: true);
  final NeonPalette p = NeonThemeExt.of(context).palette;
  final Color accent = tone.colorOf(p);

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (BuildContext ctx) => _NeonToastWidget(
      message: message,
      icon: icon ?? _toneIcon(tone),
      accent: accent,
      duration: duration,
      position: position,
      margin: margin,
      onDone: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );

  overlay.insert(entry);
  await Future<void>.delayed(duration + const Duration(milliseconds: 400));
}

class _NeonToastWidget extends StatefulWidget {
  const _NeonToastWidget({
    required this.message,
    required this.icon,
    required this.accent,
    required this.duration,
    required this.position,
    required this.margin,
    required this.onDone,
  });

  final String message;
  final IconData icon;
  final Color accent;
  final Duration duration;
  final NeonToastPosition position;
  final double margin;
  final VoidCallback onDone;

  @override
  State<_NeonToastWidget> createState() => _NeonToastWidgetState();
}

class _NeonToastWidgetState extends State<_NeonToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
    Future<void>.delayed(widget.duration, () async {
      if (!mounted) return;
      await _ctrl.reverse();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> anim = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final bool top = widget.position == NeonToastPosition.top;
    final NeonPalette p = NeonThemeExt.of(context).palette;

    return Positioned(
      left: widget.margin,
      right: widget.margin,
      top: top ? widget.margin + MediaQuery.of(context).padding.top : null,
      bottom: top
          ? null
          : widget.margin + MediaQuery.of(context).padding.bottom,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, top ? -0.3 : 0.3),
              end: Offset.zero,
            ).animate(anim),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        p.surface.withValues(alpha: 0.98),
                        p.backgroundMid.withValues(alpha: 0.95),
                      ],
                    ),
                    border: Border.all(
                      color: widget.accent.withValues(alpha: 0.55),
                      width: 1.2,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: widget.accent.withValues(alpha: 0.35),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(widget.icon, color: widget.accent, size: 18),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          widget.message,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: p.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

IconData _toneIcon(StatusTone tone) {
  switch (tone) {
    case StatusTone.neutral:
      return Icons.info_outline_rounded;
    case StatusTone.info:
      return Icons.bolt_rounded;
    case StatusTone.success:
      return Icons.check_circle_outline_rounded;
    case StatusTone.warning:
      return Icons.warning_amber_rounded;
    case StatusTone.danger:
      return Icons.error_outline_rounded;
  }
}
