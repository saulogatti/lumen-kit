import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../foundation/lumen_tokens.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';
import 'lumen_progress_indicator.dart';

/// Covers [child] with a layer that blocks touch, focus and screen reader while
/// [loading] is `true`, with spinner and [message] in the center.
/// To lock the entire screen during an operation (e.g. submit), without save
/// loading state, use [showLumenLoading].
/// ```dart
/// LumenLoadingOverlay(
///   loading: _saving,
///   message: 'Salvando…',
///   child: myForm,
/// )
/// ```
class LumenLoadingOverlay extends StatelessWidget {
  /// Creates the loading layer over [child].
  const LumenLoadingOverlay({
    required this.loading,
    required this.child,
    super.key,
    this.message,
    this.accentColor,
    this.barrierColor,
    this.borderRadius,
  });

  /// Whether to show the layer and block [child].
  final bool loading;

  /// Content covered.
  final Widget child;

  /// Text below the spinner, also announced by screen readers.
  final String? message;

  /// Panel edge accent override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Veil color on [child].
  ///
  /// Default: `palette.backgroundDeep` translucent.
  final Color? barrierColor;

  /// Cutting out the veil, to accompany the corners of [child] (e.g.: a card).
  ///
  /// Use `LumenStyle.of(context).radius(...)` to follow the style.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    return Stack(
      children: <Widget>[
        ExcludeFocus(
          excluding: loading,
          child: ExcludeSemantics(excluding: loading, child: child),
        ),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.zero,
            clipBehavior: borderRadius == null ? Clip.none : Clip.antiAlias,
            child: AnimatedSwitcher(
              duration: LumenMotion.duration(context, kLumenMediumDuration),
              child: loading
                  ? Stack(
                      key: const ValueKey<bool>(true),
                      children: <Widget>[
                        ModalBarrier(
                          dismissible: false,
                          color: barrierColor ?? _defaultBarrier(p),
                        ),
                        Center(
                          child: LumenLoadingPanel(
                            message: message,
                            accentColor: accentColor,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(key: ValueKey<bool>(false)),
            ),
          ),
        ),
      ],
    );
  }
}

Color _defaultBarrier(LumenPalette p) =>
    p.backgroundDeep.withValues(alpha: 0.6);

/// Panel with spinner and message used by [LumenLoadingOverlay] and
/// [showLumenLoading].
///
/// Useful for creating your own loading screens.
class LumenLoadingPanel extends StatelessWidget {
  /// Creates the loading panel.
  const LumenLoadingPanel({super.key, this.message, this.accentColor});

  /// Text below the spinner.
  final String? message;

  /// Accent override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle s = LumenStyle.of(context);
    final BorderRadius radius = s.radius(18);
    return Semantics(
      liveRegion: true,
      label: message,
      child: s.frost(
        borderRadius: radius,
        child: Container(
          constraints: const BoxConstraints(minWidth: 120, maxWidth: 280),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          decoration: LumenDecorations.panel(
            p,
            s,
            accent: accentColor ?? p.primary,
            radius: 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: <Widget>[
              const LumenCircularProgress(size: 40, strokeWidth: 4),
              if (message != null)
                ExcludeSemantics(
                  child: Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: p.textPrimary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lock the entire screen with [LumenLoadingPanel] while [task] runs and
/// returns its result.
///
/// The layer disappears even if [task] throws an error (the error is passed),
/// and the back button is blocked in the meantime.
/// ```dart
/// final bool ok = await showLumenLoading(
///   context: context,
///   message: 'Enviando…',
///   task: () => api.submit(form),
/// );
/// ```
Future<T> showLumenLoading<T>({
  required BuildContext context,
  required Future<T> Function() task,
  String? message,
  Color? accentColor,
  Color? barrierColor,
}) async {
  final LumenThemeExt ext = LumenThemeExt.of(context);
  final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
  final route = DialogRoute<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: barrierColor ?? _defaultBarrier(ext.palette),
    themes: InheritedTheme.capture(from: context, to: navigator.context),
    // O LumenScope não é um InheritedTheme: repassa paleta e estilo à mão
    // para a rota herdar o mesmo visual do chamador.
    builder: (BuildContext _) => LumenScope(
      palette: ext.palette,
      style: ext.style,
      child: PopScope(
        canPop: false,
        child: Center(
          child: Material(
            type: MaterialType.transparency,
            child: LumenLoadingPanel(
              message: message,
              accentColor: accentColor,
            ),
          ),
        ),
      ),
    ),
  );
  navigator.push(route);
  try {
    return await task();
  } finally {
    // removeRoute em vez de pop: não fecha por engano outra rota que tenha
    // sido aberta por cima durante a tarefa.
    if (route.isActive) {
      navigator.removeRoute(route);
    }
  }
}
