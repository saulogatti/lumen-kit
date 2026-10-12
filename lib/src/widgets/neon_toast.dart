import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../foundation/neon_decorations.dart';
import '../foundation/neon_tokens.dart';
import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';
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
/// Retorna um [Future] que completa quando o toast sai da tela.
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
}) {
  final OverlayState overlay = Overlay.of(context, rootOverlay: true);
  final NeonPalette p = NeonThemeExt.of(context).palette;
  final Completer<void> done = Completer<void>();

  late final OverlayEntry entry;
  void finish() {
    if (entry.mounted) entry.remove();
    entry.dispose();
    if (!done.isCompleted) done.complete();
  }

  entry = OverlayEntry(
    builder: (BuildContext ctx) => _NeonToastWidget(
      message: message,
      icon: icon ?? tone.icon,
      accent: tone.colorOf(p),
      duration: duration,
      position: position,
      margin: margin,
      onDone: finish,
    ),
  );

  overlay.insert(entry);
  return done.future;
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
    duration: kNeonMediumDuration,
  );
  late final CurvedAnimation _anim = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: Offset(0, widget.position == NeonToastPosition.top ? -0.3 : 0.3),
    end: Offset.zero,
  ).animate(_anim);
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ctrl.duration = NeonMotion.duration(context, kNeonMediumDuration);
    if (_ctrl.isDismissed && _timer == null) {
      _ctrl.forward();
      _timer = Timer(widget.duration, _hide);
    }
  }

  Future<void> _hide() async {
    if (!mounted) return;
    await _ctrl.reverse();
    // O OverlayEntry é removido fora do frame de build.
    widget.onDone();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anim.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool top = widget.position == NeonToastPosition.top;
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final EdgeInsets safe = MediaQuery.paddingOf(context);

    return Positioned(
      left: widget.margin,
      right: widget.margin,
      top: top ? widget.margin + safe.top : null,
      bottom: top ? null : widget.margin + safe.bottom,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _anim,
          child: SlideTransition(
            position: _slide,
            child: Center(
              // liveRegion: leitores de tela anunciam o toast ao aparecer.
              child: Semantics(
                liveRegion: true,
                container: true,
                child: Material(
                  type: MaterialType.transparency,
                  child: style.frost(
                    borderRadius: style.radius(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: NeonDecorations.panel(
                        p,
                        style,
                        accent: widget.accent,
                        radius: 999,
                        glowAlpha: 0.35,
                        glowOffset: const Offset(0, 8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 10,
                        children: <Widget>[
                          Icon(widget.icon, color: widget.accent, size: 18),
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
        ),
      ),
    );
  }
}
