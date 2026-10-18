import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

/// Checkbox controlado de fora, como o app usa.
Widget _controlled({required bool? initial, required List<bool?> log, bool tristate = false}) {
  var value = initial;
  return StatefulBuilder(
    builder: (context, setState) => LumenCheckbox(
      value: value,
      tristate: tristate,
      label: 'Aceito',
      onChanged: (next) {
        log.add(next);
        setState(() => value = next);
      },
    ),
  );
}

void main() {
  testWidgets('LumenCheckbox alterna entre false e true pelo toque', (tester) async {
    final log = <bool?>[];
    await pumpBare(tester, _controlled(initial: false, log: log));
    expect(find.byIcon(Icons.check_rounded), findsNothing);

    await tester.tap(find.text('Aceito'));
    await tester.pump();
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(find.byType(LumenCheckbox));
    await tester.pump();
    expect(log, <bool?>[true, false]);
    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });

  testWidgets('LumenCheckbox tristate passa por null antes de voltar a false', (tester) async {
    final log = <bool?>[];
    await pumpBare(tester, _controlled(initial: true, log: log, tristate: true));

    await tester.tap(find.byType(LumenCheckbox));
    await tester.pump();
    expect(log, <bool?>[null]);
    // Indeterminado: traço no lugar do check.
    expect(find.byIcon(Icons.check_rounded), findsNothing);
    expect(tester.widget<LumenPressable>(find.byType(LumenPressable)).checked, isFalse);

    await tester.tap(find.byType(LumenCheckbox));
    await tester.pump();
    expect(log, <bool?>[null, false]);
  });

  testWidgets('LumenCheckbox sem onChanged não reage ao toque', (tester) async {
    await pumpBare(tester, const LumenCheckbox(value: false, label: 'Travado', onChanged: null));
    expect(tester.widget<LumenPressable>(find.byType(LumenPressable)).onTap, isNull);

    await tester.tap(find.text('Travado'));
    await tester.pump();
    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });
}
