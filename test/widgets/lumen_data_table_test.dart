import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenDataTable mostra a célula e LumenTableRow toca', (tester) async {
    var taps = 0;
    await pumpBare(
      tester,
      SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const LumenDataTable(
              columns: <DataColumn>[DataColumn(label: Text('Nome'))],
              rows: <DataRow>[
                DataRow(cells: <DataCell>[DataCell(Text('Ada'))]),
              ],
            ),
            LumenTableRow(onTap: () => taps++, cells: const <Widget>[Text('linha')]),
          ],
        ),
      ),
    );

    expect(find.text('Ada'), findsOneWidget);
    await tester.tap(find.text('linha'));
    await tester.pump();
    expect(taps, 1);
  });
}
