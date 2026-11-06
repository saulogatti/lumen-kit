import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

Widget _picker({required ValueChanged<DateTime>? onChanged, String Function(DateTime)? format}) =>
    SizedBox(
      width: 320,
      child: LumenDatePicker(
        value: DateTime(2026, 3, 5),
        firstDate: DateTime(2026),
        lastDate: DateTime(2026, 12, 31),
        label: 'Data',
        format: format,
        onChanged: onChanged,
      ),
    );

void main() {
  testWidgets('LumenDatePicker mostra dd/MM/yyyy e devolve o dia escolhido', (tester) async {
    final picked = <DateTime>[];
    await pumpBare(tester, _picker(onChanged: picked.add));
    expect(find.text('05/03/2026'), findsOneWidget);

    await tester.tap(find.byType(LumenDatePicker));
    await tester.pumpAndSettle();
    await tester.tap(find.text('20'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(picked, <DateTime>[DateTime(2026, 3, 20)]);
  });

  testWidgets('cancelar o LumenDatePicker não chama onChanged', (tester) async {
    final picked = <DateTime>[];
    await pumpBare(tester, _picker(onChanged: picked.add));

    await tester.tap(find.byType(LumenDatePicker));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsNothing);
    expect(picked, isEmpty);
  });

  testWidgets('LumenDatePicker com value antes de firstDate abre no firstDate', (tester) async {
    await pumpBare(
      tester,
      SizedBox(
        width: 320,
        child: LumenDatePicker(
          value: DateTime(1980, 6),
          firstDate: DateTime(1990, 2),
          lastDate: DateTime(2000),
          onChanged: (_) {},
        ),
      ),
    );
    await tester.tap(find.byType(LumenDatePicker));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      tester.widget<DatePickerDialog>(find.byType(DatePickerDialog)).initialDate,
      DateTime(1990, 2),
    );
  });

  testWidgets('LumenDatePicker usa o format e não abre desabilitado', (tester) async {
    await pumpBare(tester, _picker(onChanged: null, format: (d) => 'ano ${d.year}'));
    expect(find.text('ano 2026'), findsOneWidget);

    await tester.tap(find.byType(LumenDatePicker));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsNothing);
  });
}
