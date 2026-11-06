import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenCard só vira área de toque com onTap', (tester) async {
    var taps = 0;
    await pumpBare(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const LumenCard(child: Text('estático')),
          LumenCard(onTap: () => taps++, child: const Text('tocável')),
        ],
      ),
    );

    expect(
      find.ancestor(of: find.text('estático'), matching: find.byType(LumenPressable)),
      findsNothing,
    );
    await tester.tap(find.text('tocável'));
    await tester.pump();
    expect(taps, 1);
  });
}
