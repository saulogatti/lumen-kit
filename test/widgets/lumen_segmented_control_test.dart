import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenSegmentedControl troca o segmento', (
    tester,
  ) async {
    var index = 0;
    await tester.pumpWidget(
      bareApp(
        StatefulBuilder(
          builder: (context, setState) =>
              LumenSegmentedControl(
                items: const <LumenTabItem>[
                  LumenTabItem(label: 'Dia'),
                  LumenTabItem(label: 'Semana'),
                ],
                selectedIndex: index,
                onChanged: (next) => setState(() => index = next),
              ),
        ),
      ),
    );

    await tester.tap(find.text('Semana'));
    await tester.pump();
    expect(index, 1);
  });
}
