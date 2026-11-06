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

  testWidgets('LumenStepper horizontal é só indicador: marca concluídos e avisa o toque', (
    tester,
  ) async {
    var tapped = -1;
    await pumpBare(
      tester,
      SizedBox(
        width: 360,
        child: LumenStepper(
          steps: const <LumenStep>[
            LumenStep(title: 'Conta', content: Text('form')),
            LumenStep(title: 'Meio'),
            LumenStep(title: 'Pronto'),
          ],
          currentStep: 1,
          onStepTapped: (index) => tapped = index,
        ),
      ),
    );

    expect(find.text('form'), findsNothing, reason: 'horizontal não expande conteúdo');
    expect(find.byIcon(Icons.check_rounded), findsOneWidget, reason: 'só o passo 0 concluído');
    await tester.tap(find.text('Pronto'));
    await tester.pump();
    expect(tapped, 2);
  });

  testWidgets('LumenStepper vertical mostra subtitle e check nos passos anteriores', (
    tester,
  ) async {
    await pumpBare(
      tester,
      const SizedBox(
        width: 360,
        child: LumenStepper(
          steps: <LumenStep>[
            LumenStep(title: 'Conta', subtitle: 'e-mail e senha'),
            LumenStep(title: 'Pronto', content: Text('fim')),
          ],
          currentStep: 1,
          direction: LumenStepperDirection.vertical,
        ),
      ),
    );
    expect(find.text('e-mail e senha'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.text('fim'), findsOneWidget);
  });
}
