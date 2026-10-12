import 'package:material_ui/material_ui.dart';

import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Definição de cada step.
class NeonStep {
  /// Cria a definição de um passo do [NeonStepper].
  const NeonStep({required this.title, this.subtitle, this.content});

  /// Título exibido no step.
  final String title;

  /// Texto auxiliar exibido abaixo de [title].
  final String? subtitle;

  /// Conteúdo exibido abaixo do título quando o step está ativo (apenas no
  /// modo vertical).
  final Widget? content;
}

/// Direção de apresentação do [NeonStepper].
enum NeonStepperDirection {
  /// Mostra os steps em linha como indicador de progresso.
  horizontal,

  /// Mostra os steps em coluna e expande o conteúdo do step ativo.
  vertical,
}

/// Stepper temático com bolas conectadas por linhas em gradiente. Modo
/// `horizontal` é puramente indicador; o `vertical` expande o conteúdo do
/// step ativo.
class NeonStepper extends StatelessWidget {
  /// Cria um stepper neon controlado por [currentStep].
  const NeonStepper({
    required this.steps,
    required this.currentStep,
    super.key,
    this.direction = NeonStepperDirection.horizontal,
    this.onStepTapped,
    this.accentColor,
  });

  /// Lista de steps exibidos.
  final List<NeonStep> steps;

  /// Índice do step atual.
  final int currentStep;

  /// Direção visual do stepper.
  final NeonStepperDirection direction;

  /// Callback chamado com o índice do step tocado.
  final ValueChanged<int>? onStepTapped;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return direction == NeonStepperDirection.horizontal
        ? _buildHorizontal(context)
        : _buildVertical(context);
  }

  Widget _buildHorizontal(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Color accent = accentColor ?? p.primary;

    final List<Widget> nodes = <Widget>[];
    for (int i = 0; i < steps.length; i++) {
      final bool active = i <= currentStep;
      final bool current = i == currentStep;
      nodes.add(
        InkWell(
          onTap: onStepTapped == null ? null : () => onStepTapped!(i),
          borderRadius: style.radius(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _StepCircle(
                index: i,
                accent: accent,
                palette: p,
                active: active,
                current: current,
                completed: i < currentStep,
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 80,
                child: Text(
                  steps[i].title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: active ? p.textPrimary : p.textMuted,
                    fontWeight: current ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      if (i != steps.length - 1) {
        nodes.add(
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: _Connector(
                accent: accent,
                palette: p,
                active: i < currentStep,
              ),
            ),
          ),
        );
      }
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: nodes);
  }

  Widget _buildVertical(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Color accent = accentColor ?? p.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.generate(steps.length, (int i) {
        final NeonStep s = steps[i];
        final bool current = i == currentStep;
        final bool active = i <= currentStep;
        final bool isLast = i == steps.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                children: <Widget>[
                  _StepCircle(
                    index: i,
                    accent: accent,
                    palette: p,
                    active: active,
                    current: current,
                    completed: i < currentStep,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          gradient: style.fill(
                            LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: i < currentStep
                                  ? <Color>[accent, p.secondary]
                                  : <Color>[
                                      p.surfaceOutline.withValues(alpha: 0.7),
                                      p.surfaceOutline.withValues(alpha: 0.4),
                                    ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 18, top: 4),
                  child: InkWell(
                    onTap: onStepTapped == null ? null : () => onStepTapped!(i),
                    borderRadius: style.radius(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          s.title,
                          style: TextStyle(
                            color: active ? p.textPrimary : p.textMuted,
                            fontWeight: current
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                        if (s.subtitle != null) ...<Widget>[
                          const SizedBox(height: 2),
                          Text(
                            s.subtitle!,
                            style: TextStyle(color: p.textMuted, fontSize: 12),
                          ),
                        ],
                        if (current && s.content != null) ...<Widget>[
                          const SizedBox(height: 12),
                          s.content!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.index,
    required this.accent,
    required this.palette,
    required this.active,
    required this.current,
    required this.completed,
  });

  final int index;
  final Color accent;
  final NeonPalette palette;
  final bool active;
  final bool current;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final NeonStyle style = NeonStyle.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: style.fill(
          active
              ? LinearGradient(
                  colors: <Color>[accent, palette.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        color: active
            ? null
            : palette.surface.withValues(alpha: style.surfaceAlpha(0.7)),
        border: style.borderAll(
          color: active
              ? accent
              : palette.surfaceOutline.withValues(alpha: 0.8),
          width: 1.4,
        ),
        boxShadow: style.shadows(
          current
              ? <BoxShadow>[
                  BoxShadow(
                    color: accent.withValues(alpha: 0.55),
                    blurRadius: 14,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
      ),
      child: completed
          ? Icon(Icons.check_rounded, size: 16, color: palette.textPrimary)
          : Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? palette.textPrimary : palette.textMuted,
              ),
            ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({
    required this.accent,
    required this.palette,
    required this.active,
  });

  final Color accent;
  final NeonPalette palette;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final NeonStyle style = NeonStyle.of(context);
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: style.fill(
          LinearGradient(
            colors: active
                ? <Color>[accent, palette.secondary]
                : <Color>[
                    palette.surfaceOutline.withValues(alpha: 0.6),
                    palette.surfaceOutline.withValues(alpha: 0.3),
                  ],
          ),
        ),
      ),
    );
  }
}
