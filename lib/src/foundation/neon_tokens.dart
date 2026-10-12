import 'package:material_ui/material_ui.dart';

/// Opacidade aplicada a qualquer widget desabilitado do kit.
const double kNeonDisabledOpacity = 0.55;

/// Duração das transições curtas (hover, seleção, toggle).
const Duration kNeonFastDuration = Duration(milliseconds: 180);

/// Duração das transições médias (expandir, trocar conteúdo).
const Duration kNeonMediumDuration = Duration(milliseconds: 220);

/// Helpers de movimento que respeitam "reduzir animações" do sistema.
abstract final class NeonMotion {
  /// `true` quando o usuário pediu para reduzir animações.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [duration], ou [Duration.zero] quando animações estão reduzidas.
  static Duration duration(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;

  /// Mantém [controller] em loop enquanto [active] e animações estão
  /// liberadas; caso contrário, para em [rest]. Chame em
  /// `didChangeDependencies` e `didUpdateWidget`.
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
