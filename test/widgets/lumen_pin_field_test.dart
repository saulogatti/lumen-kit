import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenPinField digita, cola e completa', (
    WidgetTester tester,
  ) async {
    var value = '';
    String? done;
    await pumpBare(
      tester,
      LumenPinField(
        value: value,
        onChanged: (String v) => value = v,
        onCompleted: (String v) => done = v,
      ),
    );
    await tester.enterText(find.byType(TextField), '12');
    await tester.pump();
    expect(value, '12');

    await tester.enterText(find.byType(TextField), '12ab3456');
    await tester.pump();
    expect(value, '123456');
    expect(done, '123456');
  });

  testWidgets('LumenPinField desabilitado não aceita texto', (
    WidgetTester tester,
  ) async {
    await pumpBare(tester, const LumenPinField(value: '1'));
    final TextField field = tester.widget<TextField>(find.byType(TextField));
    expect(field.enabled, isFalse);
  });
}
