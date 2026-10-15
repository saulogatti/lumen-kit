import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenCta toca e fica desabilitado sem onPressed', (
    tester,
  ) async {
    var taps = 0;
    await pumpBare(
      tester,
      LumenCta(label: 'EXECUTAR', onPressed: () => taps++),
    );
    await tester.tap(find.text('EXECUTAR'));
    await tester.pump();
    expect(taps, 1);

    await pumpBare(tester, const LumenCta(label: 'EXECUTAR', onPressed: null));
    expect(
      tester.widget<LumenPressable>(find.byType(LumenPressable)).onTap,
      isNull,
    );
  });
}
