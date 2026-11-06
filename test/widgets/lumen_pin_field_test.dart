import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenPinField digita, cola e completa', (tester) async {
    var value = '';
    String? done;
    await pumpBare(
      tester,
      LumenPinField(value: value, onChanged: (v) => value = v, onCompleted: (v) => done = v),
    );
    await tester.enterText(find.byType(TextField), '12');
    await tester.pump();
    expect(value, '12');

    await tester.enterText(find.byType(TextField), '12ab3456');
    await tester.pump();
    expect(value, '123456');
    expect(done, '123456');
  });

  testWidgets('LumenPinField desabilitado não aceita texto', (tester) async {
    await pumpBare(tester, const LumenPinField(value: '1'));
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.enabled, isFalse);
  });

  testWidgets('LumenPinField segue o value vindo de fora (limpar após erro)', (tester) async {
    Widget pin(String v) => bareApp(LumenPinField(value: v, onChanged: (_) {}));
    String typed() => tester.widget<TextField>(find.byType(TextField)).controller!.text;

    await tester.pumpWidget(pin('1234'));
    expect(typed(), '1234');

    await tester.pumpWidget(pin(''));
    expect(typed(), isEmpty);

    // Só dígitos e no máximo `length` (6), mesmo vindo de fora.
    await tester.pumpWidget(pin('ab12-345678'));
    expect(typed(), '123456');
  });

  testWidgets('LumenPinField não chama onCompleted de novo sem esvaziar', (tester) async {
    final done = <String>[];
    var value = '';
    await pumpBare(
      tester,
      StatefulBuilder(
        builder: (context, setState) => LumenPinField(
          value: value,
          length: 4,
          onChanged: (v) => setState(() => value = v),
          onCompleted: done.add,
        ),
      ),
    );
    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), '1234');
    await tester.pump();
    await tester.enterText(find.byType(TextField), '1235');
    await tester.pump();
    expect(done, <String>['1234']);
  });
}
