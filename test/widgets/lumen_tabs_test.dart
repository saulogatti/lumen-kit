import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenTabs recria o controller quando muda a quantidade de abas', (tester) async {
    Widget tabs(List<String> labels, int i) => bareApp(
      LumenTabs(
        items: <LumenTabItem>[for (final String l in labels) LumenTabItem(label: l)],
        selectedIndex: i,
        onChanged: (_) {},
      ),
    );

    await tester.pumpWidget(tabs(<String>['A', 'B'], 0));
    await tester.pumpWidget(tabs(<String>['A', 'B', 'C'], 2));
    await tester.pumpAndSettle();

    final controller = tester.widget<TabBar>(find.byType(TabBar)).controller!;
    expect(controller.length, 3);
    expect(controller.index, 2);
    expect(find.text('C'), findsOneWidget);
  });
}
