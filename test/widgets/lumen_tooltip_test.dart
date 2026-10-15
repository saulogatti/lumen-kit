import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenTooltip mostra a mensagem no toque longo', (
    tester,
  ) async {
    await pumpBare(
      tester,
      const LumenTooltip(
        message: 'Atalho',
        waitDuration: Duration.zero,
        child: Text('alvo'),
      ),
    );

    expect(tester.widget<Tooltip>(find.byType(Tooltip)).message, 'Atalho');
    await tester.longPress(find.text('alvo'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Atalho'), findsOneWidget);
  });
}
