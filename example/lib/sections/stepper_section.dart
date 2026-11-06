import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

/// Independent horizontal and vertical stepper demonstrations.
class StepperSection extends StatefulWidget {
  /// Creates the stepper gallery content.
  const StepperSection({super.key});

  @override
  State<StepperSection> createState() => _StepperSectionState();
}

class _StepperSectionState extends State<StepperSection>
    with AutomaticKeepAliveClientMixin<StepperSection> {
  int _horizontalStep = 1;
  int _verticalStep = 1;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final textTheme = Theme.of(context).textTheme;
    final heading = textTheme.titleSmall?.copyWith(color: p.textPrimary);
    final body = textTheme.bodyMedium?.copyWith(color: p.textSecondary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: <Widget>[
        Text('Horizontal', style: heading),
        Text(
          'Tap a step to change progress. Earlier steps are completed.',
          style: body,
        ),
        LumenStepper(
          key: const ValueKey<String>('horizontal-stepper'),
          currentStep: _horizontalStep,
          direction: LumenStepperDirection.horizontal,
          onStepTapped: (int step) => setState(() => _horizontalStep = step),
          steps: const <LumenStep>[
            LumenStep(title: 'Account'),
            LumenStep(title: 'Profile'),
            LumenStep(title: 'Done'),
          ],
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: LumenButton.ghost(
            label: 'Reset horizontal',
            icon: Icons.restart_alt_rounded,
            onPressed: _horizontalStep == 0
                ? null
                : () => setState(() => _horizontalStep = 0),
          ),
        ),
        Text('Vertical', style: heading),
        Text('Only the active step expands its content.', style: body),
        LumenStepper(
          key: const ValueKey<String>('vertical-stepper'),
          currentStep: _verticalStep,
          direction: LumenStepperDirection.vertical,
          onStepTapped: (int step) => setState(() => _verticalStep = step),
          steps: <LumenStep>[
            LumenStep(
              title: 'Account',
              subtitle: 'Create credentials',
              content: Text(
                'Choose an email address and a secure password.',
                style: body,
              ),
            ),
            LumenStep(
              title: 'Profile',
              subtitle: 'Personal details',
              content: Text(
                'Add your name and choose a profile picture.',
                style: body,
              ),
            ),
            LumenStep(
              title: 'Done',
              subtitle: 'Review and finish',
              content: Text(
                'Your account is ready. Review your details to finish.',
                style: body,
              ),
            ),
          ],
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: LumenButton.ghost(
            label: 'Reset vertical',
            icon: Icons.restart_alt_rounded,
            onPressed: _verticalStep == 0
                ? null
                : () => setState(() => _verticalStep = 0),
          ),
        ),
      ],
    );
  }
}
