import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenTag toca quando tem onTap e só mostra o texto sem ele', (
    WidgetTester tester,
  ) async {
    var taps = 0;
    await pumpBare(tester, LumenTag(label: 'beta', onTap: () => taps++));
    await tester.tap(find.text('beta'));
    await tester.pump();
    expect(taps, 1);

    await pumpBare(tester, const LumenTag(label: 'novo'));
    expect(find.byType(LumenPressable), findsNothing);
    expect(find.text('novo'), findsOneWidget);
  });
}
