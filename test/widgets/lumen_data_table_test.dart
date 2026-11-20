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

  testWidgets('LumenDataTable monta as linhas a partir de dados', (tester) async {
    await pumpBare(
      tester,
      LumenDataTable(
        columns: const <DataColumn>[
          DataColumn(label: Text('Nome')),
          DataColumn(label: Text('Idade'), numeric: true),
        ],
        rows: <DataRow>[
          for (final (name, age) in <(String, int)>[('Ada', 36), ('Alan', 41)])
            DataRow(cells: <DataCell>[DataCell(Text(name)), DataCell(Text('$age'))]),
        ],
      ),
    );

    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Alan'), findsOneWidget);
    expect(find.text('41'), findsOneWidget);
  });

  testWidgets('LumenDataTable pinta a linha selecionada com o accent', (tester) async {
    const accent = Color(0xFF00E5FF);
    await pumpBare(
      tester,
      const LumenDataTable(
        accentColor: accent,
        columns: <DataColumn>[DataColumn(label: Text('Nome'))],
        rows: <DataRow>[
          DataRow(selected: true, cells: <DataCell>[DataCell(Text('Ada'))]),
        ],
      ),
    );
    final rowColor = tester.widget<DataTable>(find.byType(DataTable)).dataRowColor!;
    expect(rowColor.resolve(<WidgetState>{WidgetState.selected}), accent.withValues(alpha: 0.16));
    expect(rowColor.resolve(<WidgetState>{}), isNull);
  });
}
