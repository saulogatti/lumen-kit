import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenRadio devolve o próprio valor e ignora a opção desabilitada', (tester) async {
    int? group = 1;
    await pumpBare(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          void pick(int? v) => setState(() => group = v);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              LumenRadio<int>(value: 1, groupValue: group, label: 'Um', onChanged: pick),
              LumenRadio<int>(value: 2, groupValue: group, label: 'Dois', onChanged: pick),
              LumenRadio<int>(value: 3, groupValue: group, label: 'Três', onChanged: null),
            ],
          );
        },
      ),
    );

    bool? checked(String label) => tester
        .widget<LumenPressable>(
          find.ancestor(of: find.text(label), matching: find.byType(LumenPressable)),
        )
        .checked;

    expect(checked('Um'), isTrue);
    await tester.tap(find.text('Dois'));
    await tester.pump();
    expect(group, 2);
    expect(checked('Dois'), isTrue);
    expect(checked('Um'), isFalse);

    await tester.tap(find.text('Três'));
    await tester.pump();
    expect(group, 2);
  });
}
