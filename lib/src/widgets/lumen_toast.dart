import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../foundation/lumen_tokens.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';
import 'lumen_status_chip.dart';

/// Vertical position of the toast on the screen.
enum LumenToastPosition {
  /// Toast aligned close to the top, respecting safe padding.
  top,

  /// Toast aligned close to the base, respecting safe padding.
  bottom,
}

/// Displays a floating toast over the app via `Overlay`, without depending on
/// `ScaffoldMessenger`.
///
/// Useful for quick feedback on screens without `Scaffold` (e.g. splash,
/// onboarding).
/// Returns a [Future] that completes when the toast leaves the screen.
/// [tone] sets default color and icon, [position] chooses vertical alignment
/// and [margin] controls the horizontal and vertical distance from safe edges.
Future<void> showLumenToast({
  required BuildContext context,
  required String message,
  LumenStatusTone tone = LumenStatusTone.info,
  IconData? icon,
  Duration duration = const Duration(seconds: 3),
  LumenToastPosition position = LumenToastPosition.bottom,
  double margin = 24,
}) {
  final OverlayState overlay = Overlay.of(context, rootOverlay: true);
  final LumenPalette p = LumenThemeExt.of(context).palette;
  final done = Completer<void>();

  late final OverlayEntry entry;
  void finish() {
    if (entry.mounted) {
      entry.remove();
    }
    entry.dispose();
    if (!done.isCompleted) {
      done.complete();
    }
  }

  entry = OverlayEntry(
    builder: (BuildContext ctx) => _LumenToastWidget(
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

class _LumenToastWidget extends StatefulWidget {
  const _LumenToastWidget({
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
  final LumenToastPosition position;
  final double margin;
  final VoidCallback onDone;

  @override
  State<_LumenToastWidget> createState() => _LumenToastWidgetState();
}

class _LumenToastWidgetState extends State<_LumenToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: kLumenMediumDuration,
  );
  late final CurvedAnimation _anim = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: Offset(0, widget.position == LumenToastPosition.top ? -0.3 : 0.3),
    end: Offset.zero,
  ).animate(_anim);
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ctrl.duration = LumenMotion.duration(context, kLumenMediumDuration);
    if (_ctrl.isDismissed && _timer == null) {
      _ctrl.forward();
      _timer = Timer(widget.duration, _hide);
    }
  }

  Future<void> _hide() async {
    if (!mounted) {
      return;
    }
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
    final top = widget.position == LumenToastPosition.top;
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
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
                      decoration: LumenDecorations.panel(
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
