import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

Widget _view(Widget sliver, {double width = 320}) => SizedBox(
  width: width,
  height: 300,
  child: CustomScrollView(slivers: <Widget>[sliver]),
);

Finder _cell(String title) => find.widgetWithText(LumenGridTile, title);

void main() {
  testWidgets('LumenSliverGrid constrói só o visível e toca a célula', (tester) async {
    int? tapped;
    await pumpBare(
      tester,
      _view(
        LumenSliverGrid(
          crossAxisCount: 2,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          addSemanticIndexes: false,
          itemCount: 80,
          itemBuilder: (context, i) => LumenGridTile(title: 'item $i', onTap: () => tapped = i),
        ),
      ),
    );
    expect(find.text('item 0'), findsOneWidget);
    expect(find.text('item 79'), findsNothing);
    await tester.tap(find.text('item 1'));
    await tester.pump();
    expect(tapped, 1);
  });

  testWidgets('LumenSliverGrid divide a largura por crossAxisCount com o espaçamento', (
    tester,
  ) async {
    await pumpBare(
      tester,
      _view(
        LumenSliverGrid(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          itemCount: 6,
          itemBuilder: (context, i) => LumenGridTile(title: 'c$i'),
        ),
      ),
    );
    // (320 - 2 * 10) / 3 = 100, quadrada pelo childAspectRatio padrão.
    expect(tester.getSize(_cell('c0')), const Size(100, 100));
    expect(tester.getTopLeft(_cell('c3')).dy - tester.getTopLeft(_cell('c0')).dy, 110);
  });

  testWidgets('LumenSliverGrid.extent ajusta as colunas à largura e respeita mainAxisExtent', (
    tester,
  ) async {
    Widget grid(double width) => _view(
      width: width,
      LumenSliverGrid.extent(
        maxCrossAxisExtent: 100,
        mainAxisExtent: 80,
        crossAxisSpacing: 0,
        itemCount: 8,
        itemBuilder: (context, i) => LumenGridTile(title: 'c$i'),
      ),
    );

    await pumpBare(tester, grid(200));
    expect(tester.getSize(_cell('c0')), const Size(100, 80));
    // Duas colunas: a terceira célula desce para a segunda linha.
    expect(tester.getTopLeft(_cell('c2')).dy, greaterThan(tester.getTopLeft(_cell('c0')).dy));

    await pumpBare(tester, grid(400));
    // Quatro colunas: a terceira célula fica na primeira linha.
    expect(tester.getTopLeft(_cell('c2')).dy, tester.getTopLeft(_cell('c0')).dy);
  });

  testWidgets('LumenSliverGrid vazia mostra empty com padding, ou nada sem ele', (tester) async {
    await pumpBare(
      tester,
      _view(
        LumenSliverGrid(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16),
          itemCount: 0,
          empty: const Text('nenhum módulo'),
          itemBuilder: (context, i) => Text('item $i'),
        ),
      ),
    );
    expect(
      tester.getTopLeft(find.text('nenhum módulo')),
      tester.getTopLeft(find.byType(CustomScrollView)) + const Offset(16, 16),
    );

    await pumpBare(
      tester,
      _view(
        LumenSliverGrid.extent(
          maxCrossAxisExtent: 120,
          itemCount: 0,
          itemBuilder: (context, i) => Text('item $i'),
        ),
      ),
    );
    expect(find.byType(SliverGrid), findsNothing);
  });

  testWidgets('LumenSliverGrid aplica padding em volta das células', (tester) async {
    await pumpBare(
      tester,
      _view(
        LumenSliverGrid(
          crossAxisCount: 2,
          crossAxisSpacing: 0,
          padding: const EdgeInsets.all(20),
          itemCount: 4,
          itemBuilder: (context, i) => LumenGridTile(title: 'c$i'),
        ),
      ),
    );
    expect(
      tester.getTopLeft(_cell('c0')),
      tester.getTopLeft(find.byType(CustomScrollView)) + const Offset(20, 20),
    );
    expect(tester.getSize(_cell('c0')).width, 140);
  });

  test('LumenSliverGrid recusa colunas e largura não positivas', () {
    expect(
      () => LumenSliverGrid(
        crossAxisCount: 0,
        itemCount: 1,
        itemBuilder: (context, i) => const Text(''),
      ),
      throwsAssertionError,
    );
    expect(
      () => LumenSliverGrid.extent(
        maxCrossAxisExtent: 0,
        itemCount: 1,
        itemBuilder: (context, i) => const Text(''),
      ),
      throwsAssertionError,
    );
  });
}
