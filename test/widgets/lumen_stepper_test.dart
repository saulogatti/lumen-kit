import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

const List<LumenStep> _steps = <LumenStep>[
  LumenStep(title: 'Conta', content: Text('form')),
  LumenStep(title: 'Pronto', content: Text('fim')),
];

void main() {
  testWidgets('LumenStepper avisa o passo tocado e só expande o atual', (tester) async {
    var tapped = -1;
    await pumpBare(
      tester,
      SizedBox(
        width: 360,
        child: LumenStepper(
          steps: _steps,
          currentStep: 0,
          direction: LumenStepperDirection.vertical,
          onStepTapped: (index) => tapped = index,
        ),
      ),
    );

    expect(find.text('form'), findsOneWidget);
    expect(find.text('fim'), findsNothing);

    await tester.tap(find.text('Pronto'));
    await tester.pump();
    expect(tapped, 1);
  });
}
