import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenFab toca, estende o rótulo e bloqueia quando busy', (
    WidgetTester tester,
  ) async {
    var taps = 0;
    await pumpBare(tester, LumenFab(icon: Icons.add, onPressed: () => taps++));
    await tester.tap(find.byType(LumenFab));
    await tester.pump();
    expect(taps, 1);

    await pumpBare(
      tester,
      LumenFab.extended(
        icon: Icons.add,
        label: 'Criar',
        onPressed: () {},
        busy: true,
      ),
    );
    expect(find.text('Criar'), findsOneWidget);
    expect(
      tester.widget<LumenPressable>(find.byType(LumenPressable)).enabled,
      isFalse,
    );
  });
}
