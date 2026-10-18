import 'package:lumen_kit/src/foundation/lumen_decorations.dart';
import 'package:lumen_kit/src/foundation/lumen_pressable.dart';
import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Definition of each step.
class LumenStep {
  /// Creates a [LumenStepper] one-step definition.
  const LumenStep({required this.title, this.subtitle, this.content});

  /// Title displayed on the step.
  final String title;

  /// Auxiliary text displayed below [title].
  final String? subtitle;

  /// Content displayed below the title when the step is active (only in vertical
  /// mode).
  final Widget? content;
}

/// [LumenStepper] presentation direction.
enum LumenStepperDirection {
  /// Shows steps in line as a progress indicator.
  horizontal,

  /// Shows the steps in a column and expands the content of the active step.
  vertical,
}

/// Themed stepper with balls connected by gradient lines.
///
/// Mode `horizontal` is purely indicator; `vertical` expands the content of
/// active step.
class LumenStepper extends StatelessWidget {
  /// Creates a neon stepper controlled by [currentStep].
  const LumenStepper({
    required this.steps,
    required this.currentStep,
    super.key,
    this.direction = LumenStepperDirection.horizontal,
    this.onStepTapped,
    this.accentColor,
  });

  /// List of displayed steps.
  final List<LumenStep> steps;

  /// Current step index.
  final int currentStep;

  /// Visual direction of the stepper.
  final LumenStepperDirection direction;

  /// Callback called with the index of the played step.
  final ValueChanged<int>? onStepTapped;

  /// Highlight color override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return direction == LumenStepperDirection.horizontal
        ? _buildHorizontal(context)
        : _buildVertical(context);
  }

  Widget _buildHorizontal(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final accent = accentColor ?? p.primary;

    final nodes = <Widget>[];
    for (var i = 0; i < steps.length; i++) {
      final active = i <= currentStep;
      final current = i == currentStep;
      nodes.add(
        LumenPressable(
          onTap: onStepTapped == null ? null : () => onStepTapped!(i),
          selected: current,
          dimWhenDisabled: false,
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
              child: _Connector(accent: accent, palette: p, active: i < currentStep),
            ),
          ),
        );
      }
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: nodes);
  }

  Widget _buildVertical(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final accent = accentColor ?? p.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.generate(steps.length, (i) {
        final s = steps[i];
        final current = i == currentStep;
        final active = i <= currentStep;
        final isLast = i == steps.length - 1;
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
                                      p.surfaceOutline.outlineAlpha(0.7),
                                      p.surfaceOutline.outlineAlpha(0.4),
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
                  child: LumenPressable(
                    onTap: onStepTapped == null ? null : () => onStepTapped!(i),
                    selected: current,
                    dimWhenDisabled: false,
                    borderRadius: style.radius(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          s.title,
                          style: TextStyle(
                            color: active ? p.textPrimary : p.textMuted,
                            fontWeight: current ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        if (s.subtitle case final String subtitle) ...<Widget>[
                          const SizedBox(height: 2),
                          Text(subtitle, style: TextStyle(color: p.textMuted, fontSize: 12)),
                        ],
                        if (s.content case final Widget content when current) ...<Widget>[
                          const SizedBox(height: 12),
                          content,
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
  final LumenPalette palette;
  final bool active;
  final bool current;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final style = LumenStyle.of(context);
    return AnimatedContainer(
      duration: LumenMotion.duration(context, kLumenMediumDuration),
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: style.fill(active ? LumenDecorations.accent(palette, accent) : null),
        color: active ? null : palette.surface.withValues(alpha: style.surfaceAlpha(0.7)),
        border: style.borderAll(
          color: active ? accent : palette.surfaceOutline.outlineAlpha(0.8),
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
  const _Connector({required this.accent, required this.palette, required this.active});

  final Color accent;
  final LumenPalette palette;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final style = LumenStyle.of(context);
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: style.fill(
          LinearGradient(
            colors: active
                ? <Color>[accent, palette.secondary]
                : <Color>[
                    palette.surfaceOutline.outlineAlpha(0.6),
                    palette.surfaceOutline.outlineAlpha(0.3),
                  ],
          ),
        ),
      ),
    );
  }
}
