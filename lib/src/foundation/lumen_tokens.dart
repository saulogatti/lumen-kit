import 'package:material_ui/material_ui.dart';

/// Opacity applied to any disabled widgets in the kit.
const double kLumenDisabledOpacity = 0.55;

/// Duration of short transitions (hover, selection, toggle).
const Duration kLumenFastDuration = Duration(milliseconds: 180);

/// Duration of average transitions (expand, swap content).
const Duration kLumenMediumDuration = Duration(milliseconds: 220);

/// Motion helpers that respect the system's "reduce animations".
abstract final class LumenMotion {
  /// `true` when user asked to reduce animations.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [duration], or [Duration.zero] when animations are reduced.
  static Duration duration(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;

  /// Keeps [controller] in loop while [active] and animations are released;
  /// otherwise, it stops at [rest].
  ///
  /// Call in `didChangeDependencies` and `didUpdateWidget`.
  static void syncRepeat(
    AnimationController controller,
    BuildContext context, {
    bool active = true,
    double rest = 0.5,
  }) {
    if (active && !reduced(context)) {
      if (!controller.isAnimating) {
        controller.repeat();
      }
    } else {
      controller
        ..stop()
        ..value = rest;
    }
  }
}
