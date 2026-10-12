import 'package:material_ui/material_ui.dart';

import '../foundation/neon_decorations.dart';
import '../foundation/neon_tokens.dart';
import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';
import 'neon_progress_indicator.dart';

/// Cobre [child] com uma camada que bloqueia toque, foco e leitor de tela
/// enquanto [loading] é `true`, com spinner e [message] no centro.
///
/// Para bloquear a tela inteira durante uma operação (ex.: submit), sem
/// guardar estado de loading, use [showNeonLoading].
///
/// ```dart
/// NeonLoadingOverlay(
///   loading: _saving,
///   message: 'Salvando…',
///   child: myForm,
/// )
/// ```
class NeonLoadingOverlay extends StatelessWidget {
  /// Cria a camada de loading sobre [child].
  const NeonLoadingOverlay({
    required this.loading,
    required this.child,
    super.key,
    this.message,
    this.accentColor,
    this.barrierColor,
    this.borderRadius,
  });

  /// Se `true`, mostra a camada e bloqueia [child].
  final bool loading;

  /// Conteúdo coberto.
  final Widget child;

  /// Texto abaixo do spinner, também anunciado por leitores de tela.
  final String? message;

  /// Override do accent da borda do painel. Default: `palette.primary`.
  final Color? accentColor;

  /// Cor do véu sobre [child]. Default: `palette.backgroundDeep` translúcido.
  final Color? barrierColor;

  /// Recorte do véu, para acompanhar os cantos de [child] (ex.: um card).
  /// Use `NeonStyle.of(context).radius(...)` para seguir o estilo.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
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
              duration: NeonMotion.duration(context, kNeonMediumDuration),
              child: loading
                  ? Stack(
                      key: const ValueKey<bool>(true),
                      children: <Widget>[
                        ModalBarrier(
                          dismissible: false,
                          color: barrierColor ?? _defaultBarrier(p),
                        ),
                        Center(
                          child: NeonLoadingPanel(
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

Color _defaultBarrier(NeonPalette p) => p.backgroundDeep.withValues(alpha: 0.6);

/// Painel com spinner e mensagem usado pelo [NeonLoadingOverlay] e pelo
/// [showNeonLoading]. Útil para montar telas de loading próprias.
class NeonLoadingPanel extends StatelessWidget {
  /// Cria o painel de loading.
  const NeonLoadingPanel({super.key, this.message, this.accentColor});

  /// Texto abaixo do spinner.
  final String? message;

  /// Override do accent. Default: `palette.primary`.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle s = NeonStyle.of(context);
    final BorderRadius radius = s.radius(18);
    return Semantics(
      liveRegion: true,
      label: message,
      child: s.frost(
        borderRadius: radius,
        child: Container(
          constraints: const BoxConstraints(minWidth: 120, maxWidth: 280),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          decoration: NeonDecorations.panel(
            p,
            s,
            accent: accentColor ?? p.primary,
            radius: 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: <Widget>[
              const NeonCircularProgress(size: 40, strokeWidth: 4),
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

/// Bloqueia a tela inteira com o [NeonLoadingPanel] enquanto [task] roda e
/// devolve o resultado dela. A camada some mesmo se [task] lançar erro (o
/// erro é repassado), e o botão voltar fica bloqueado nesse meio-tempo.
///
/// ```dart
/// final bool ok = await showNeonLoading(
///   context: context,
///   message: 'Enviando…',
///   task: () => api.submit(form),
/// );
/// ```
Future<T> showNeonLoading<T>({
  required BuildContext context,
  required Future<T> Function() task,
  String? message,
  Color? accentColor,
  Color? barrierColor,
}) async {
  final NeonThemeExt ext = NeonThemeExt.of(context);
  final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
  final route = DialogRoute<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: barrierColor ?? _defaultBarrier(ext.palette),
    themes: InheritedTheme.capture(from: context, to: navigator.context),
    // O NeonScope não é um InheritedTheme: repassa paleta e estilo à mão
    // para a rota herdar o mesmo visual do chamador.
    builder: (BuildContext _) => NeonScope(
      palette: ext.palette,
      style: ext.style,
      child: PopScope(
        canPop: false,
        child: Center(
          child: Material(
            type: MaterialType.transparency,
            child: NeonLoadingPanel(message: message, accentColor: accentColor),
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
