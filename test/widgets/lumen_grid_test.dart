import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenGrid constrói só o visível e toca a célula', (tester) async {
    int? tapped;
    await pumpBare(
      tester,
      SizedBox(
        height: 240,
        width: 320,
        child: LumenGrid(
          crossAxisCount: 2,
          controller: ScrollController(),
          physics: const BouncingScrollPhysics(),
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          addSemanticIndexes: false,
          clipBehavior: Clip.antiAlias,
          itemCount: 80,
          itemBuilder: (context, i) => LumenGridTile(title: 'item $i', onTap: () => tapped = i),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('item 0'), findsOneWidget);
    expect(find.text('item 79'), findsNothing);
    await tester.tap(find.text('item 1'));
    await tester.pump();
    expect(tapped, 1);
  });

  testWidgets('LumenGrid divide a largura por crossAxisCount com o espaçamento', (tester) async {
    await pumpBare(
      tester,
      SizedBox(
        height: 300,
        width: 320,
        child: LumenGrid(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          itemCount: 6,
          itemBuilder: (context, i) => LumenGridTile(title: 'c$i'),
        ),
      ),
    );
    // (320 - 2 * 10) / 3 = 100, quadrada pelo childAspectRatio padrão.
    expect(tester.getSize(find.widgetWithText(LumenGridTile, 'c0')), const Size(100, 100));
    expect(tester.getTopLeft(find.widgetWithText(LumenGridTile, 'c1')).dx, greaterThan(100));
    expect(
      tester.getTopLeft(find.widgetWithText(LumenGridTile, 'c3')).dy -
          tester.getTopLeft(find.widgetWithText(LumenGridTile, 'c0')).dy,
      110,
    );
  });

  testWidgets('LumenGrid.extent ajusta as colunas à largura e respeita mainAxisExtent', (
    tester,
  ) async {
    Widget grid(double width) => SizedBox(
      height: 300,
      width: width,
      child: LumenGrid.extent(
        maxCrossAxisExtent: 100,
        mainAxisExtent: 80,
        crossAxisSpacing: 0,
        itemCount: 8,
        itemBuilder: (context, i) => LumenGridTile(title: 'c$i'),
      ),
    );

    await pumpBare(tester, grid(200));
    expect(tester.getSize(find.widgetWithText(LumenGridTile, 'c0')), const Size(100, 80));
    // Duas colunas: a terceira célula desce para a segunda linha.
    expect(
      tester.getTopLeft(find.widgetWithText(LumenGridTile, 'c2')).dy,
      greaterThan(tester.getTopLeft(find.widgetWithText(LumenGridTile, 'c0')).dy),
    );

    await pumpBare(tester, grid(400));
    // Quatro colunas: a terceira célula fica na primeira linha.
    expect(
      tester.getTopLeft(find.widgetWithText(LumenGridTile, 'c2')).dy,
      tester.getTopLeft(find.widgetWithText(LumenGridTile, 'c0')).dy,
    );
  });

  testWidgets('LumenGrid vazia mostra empty, ou nada sem ele', (tester) async {
    await pumpBare(
      tester,
      LumenGrid(
        crossAxisCount: 2,
        itemCount: 0,
        empty: const Text('nenhum módulo'),
        itemBuilder: (context, i) => Text('item $i'),
      ),
    );
    expect(find.text('nenhum módulo'), findsOneWidget);
    expect(find.byType(GridView), findsNothing);

    await pumpBare(
      tester,
      LumenGrid.extent(
        maxCrossAxisExtent: 120,
        itemCount: 0,
        itemBuilder: (context, i) => Text('item $i'),
      ),
    );
    expect(find.byType(GridView), findsNothing);
  });

  test('LumenGrid recusa colunas e largura não positivas', () {
    expect(
      () => LumenGrid(crossAxisCount: 0, itemCount: 1, itemBuilder: (context, i) => const Text('')),
      throwsAssertionError,
    );
    expect(
      () => LumenGrid.extent(
        maxCrossAxisExtent: 0,
        itemCount: 1,
        itemBuilder: (context, i) => const Text(''),
      ),
      throwsAssertionError,
    );
  });
}
