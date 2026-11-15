import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Reveals its child once with a fade and a fractional slide.
///
/// Supply a new key to replay the entrance. Reduced motion shows the child
/// immediately. This wrapper adds no colors or surfaces, preserving the child's
/// theme, focus behavior, and semantics.
class LumenEntrance extends StatefulWidget {
  /// Creates an entrance transition.
  const LumenEntrance({
    required this.child,
    super.key,
    this.duration = kLumenMediumDuration,
    this.curve = Curves.easeOutCubic,
    this.offset = const Offset(0, 0.08),
  });

  /// Content to reveal.
  final Widget child;

  /// Time taken to reveal [child].
  final Duration duration;

  /// Easing used for opacity and displacement.
  final Curve curve;

  /// Starting displacement as a fraction of the child's size.
  final Offset offset;

  @override
  State<LumenEntrance> createState() => _LumenEntranceState();
}

class _LumenEntranceState extends State<LumenEntrance> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  bool _started = false;

  void _syncMotion() {
    _controller.duration = LumenMotion.duration(context, widget.duration);
    if (LumenMotion.reduced(context) || widget.duration == Duration.zero) {
      _controller.value = 1;
      _started = true;
    } else if (!_started) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  @override
  void didUpdateWidget(LumenEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncMotion();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (context, child) {
      final value = widget.curve.transform(_controller.value);
      return Opacity(
        opacity: value.clamp(0, 1),
        child: FractionalTranslation(translation: widget.offset * (1 - value), child: child),
      );
    },
  );
}

/// Fades and slides between children with different types or keys.
///
/// Give each logical child a distinct [ValueKey] to animate content changes.
/// Outgoing children cannot receive pointer input, focus, or accessibility
/// actions. With reduced motion, only the current child is built.
class LumenAnimatedSwitcher extends StatelessWidget {
  /// Creates a content transition.
  const LumenAnimatedSwitcher({
    required this.child,
    super.key,
    this.duration = kLumenMediumDuration,
    this.curve = Curves.easeOutCubic,
    this.offset = const Offset(0, 0.08),
    this.alignment = Alignment.center,
  });

  /// Current content; use a distinct key for each logical state.
  final Widget child;

  /// Duration of both the incoming and outgoing transition.
  final Duration duration;

  /// Easing used for both transitions.
  final Curve curve;

  /// Displacement of a fully faded child, relative to its own size.
  final Offset offset;

  /// Alignment of incoming and outgoing children.
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    if (LumenMotion.reduced(context)) {
      return child;
    }
    return AnimatedSwitcher(
      duration: LumenMotion.duration(context, duration),
      switchInCurve: curve,
      switchOutCurve: curve,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation.drive(CurveTween(curve: const Interval(0, 1))),
        child: SlideTransition(
          position: animation.drive(Tween<Offset>(begin: offset, end: Offset.zero)),
          child: child,
        ),
      ),
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: alignment,
        children: <Widget>[
          for (final Widget previous in previousChildren)
            ExcludeFocus(
              child: ExcludeSemantics(child: IgnorePointer(child: previous)),
            ),
          ?currentChild,
        ],
      ),
      child: child,
    );
  }
}
