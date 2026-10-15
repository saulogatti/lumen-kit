import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenDropdown troca o valor e ignora toque se desabilitado', (
    tester,
  ) async {
    String? value = 'cyan';
    await tester.pumpWidget(
      bareApp(
        StatefulBuilder(
          builder: (context, setState) =>
              LumenDropdown<String>(
                label: 'Accent',
                value: value,
                items: const <LumenDropdownItem<String>>[
                  LumenDropdownItem(value: 'cyan', label: 'Cyan'),
                  LumenDropdownItem(value: 'magenta', label: 'Magenta'),
                ],
                onChanged: (next) => setState(() => value = next),
              ),
        ),
      ),
    );

    await tester.tap(find.byType(LumenDropdown<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Magenta').last);
    await tester.pumpAndSettle();
    expect(value, 'magenta');

    await pumpBare(
      tester,
      const LumenDropdown<String>(
        value: 'cyan',
        items: <LumenDropdownItem<String>>[
          LumenDropdownItem(value: 'cyan', label: 'Cyan'),
        ],
        onChanged: null,
      ),
    );
    expect(
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byType(DropdownButtonFormField<String>),
          )
          .onChanged,
      isNull,
    );
    await tester.tap(find.byType(LumenDropdown<String>));
    await tester.pumpAndSettle();
    expect(find.text('Cyan'), findsOneWidget);
  });
}
