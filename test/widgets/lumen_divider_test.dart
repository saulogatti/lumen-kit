import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenDivider mostra o rótulo e o flat não quebra', (
    WidgetTester tester,
  ) async {
    await pumpBare(
      tester,
      const SizedBox(width: 200, child: LumenDivider(label: 'ou')),
    );
    expect(find.text('ou'), findsOneWidget);

    await tester.pumpWidget(
      LumenScope(
        palette: LumenPalette.light(),
        style: LumenStyle.flat,
        child: bareApp(const SizedBox(width: 200, child: LumenDivider())),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
