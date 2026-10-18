import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenBanner mostra a ação e o fechar', (tester) async {
    var actions = 0;
    var dismisses = 0;
    await pumpBare(
      tester,
      LumenBanner(
        message: 'Sincronização pausada',
        actionLabel: 'Retomar',
        onAction: () => actions++,
        onDismiss: () => dismisses++,
      ),
    );
    expect(find.text('Sincronização pausada'), findsOneWidget);
    await tester.tap(find.text('Retomar'));
    await tester.pump();
    expect(actions, 1);

    await tester.tap(find.byTooltip('Fechar'));
    await tester.pump();
    expect(dismisses, 1);
  });

  testWidgets('LumenBanner sem onDismiss não oferece fechar', (tester) async {
    await pumpBare(tester, const LumenBanner(message: 'Fica até alguém resolver'));
    expect(find.byTooltip('Fechar'), findsNothing);
    expect(find.text('Fica até alguém resolver'), findsOneWidget);
  });
}
