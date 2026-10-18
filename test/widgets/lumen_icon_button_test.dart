import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

BorderRadius? _radius(WidgetTester tester) =>
    tester.widget<LumenPressable>(find.byType(LumenPressable)).borderRadius;

void main() {
  testWidgets('LumenIconButton rounded usa canto fixo; circle, meio do tamanho', (tester) async {
    await pumpBare(tester, LumenIconButton(icon: Icons.add, size: 48, onPressed: () {}));
    expect(_radius(tester), BorderRadius.circular(24));

    await pumpBare(
      tester,
      LumenIconButton(
        icon: Icons.add,
        size: 48,
        shape: LumenIconButtonShape.rounded,
        onPressed: () {},
      ),
    );
    expect(_radius(tester), BorderRadius.circular(12));
  });
}
