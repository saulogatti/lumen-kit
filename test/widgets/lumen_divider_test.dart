import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenDivider mostra o rótulo e o flat não quebra', (tester) async {
    await pumpBare(tester, const SizedBox(width: 200, child: LumenDivider(label: 'ou')));
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

  testWidgets('LumenDivider vertical ocupa a espessura e respeita os recuos', (tester) async {
    await pumpBare(
      tester,
      const SizedBox(
        height: 100,
        child: LumenDivider(vertical: true, thickness: 2, indent: 10, endIndent: 20),
      ),
    );
    final size = tester.getSize(find.byType(LumenDivider));
    expect(size.width, 2);
    final line = tester.getSize(
      find.descendant(of: find.byType(LumenDivider), matching: find.byType(Container)),
    );
    expect(line.height, 70);
  });
}
