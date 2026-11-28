import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

Widget _view(Widget sliver) =>
    SizedBox(width: 320, height: 240, child: CustomScrollView(slivers: <Widget>[sliver]));

void main() {
  testWidgets('LumenSliverList constrói só o visível e toca o item', (tester) async {
    int? tapped;
    await pumpBare(
      tester,
      _view(
        LumenSliverList(
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          addSemanticIndexes: false,
          itemCount: 80,
          itemBuilder: (context, i) => LumenListTile(title: 'item $i', onTap: () => tapped = i),
        ),
      ),
    );
    expect(find.text('item 0'), findsOneWidget);
    expect(find.text('item 79'), findsNothing);
    await tester.tap(find.text('item 1'));
    await tester.pump();
    expect(tapped, 1);
  });

  testWidgets('LumenSliverList com separatorBuilder põe separador só entre itens', (tester) async {
    await pumpBare(
      tester,
      _view(
        LumenSliverList(
          itemCount: 3,
          itemBuilder: (context, i) => Text('item $i'),
          separatorBuilder: (context, i) => const LumenDivider(),
        ),
      ),
    );
    expect(find.byType(LumenDivider), findsNWidgets(2));
  });

  testWidgets('LumenSliverList vazia mostra empty, ou nada sem ele', (tester) async {
    await pumpBare(
      tester,
      _view(
        LumenSliverList(
          itemCount: 0,
          empty: const Text('nenhum evento'),
          itemBuilder: (context, i) => Text('item $i'),
        ),
      ),
    );
    expect(find.text('nenhum evento'), findsOneWidget);
    expect(find.text('item 0'), findsNothing);

    await pumpBare(
      tester,
      _view(LumenSliverList(itemCount: 0, itemBuilder: (context, i) => Text('item $i'))),
    );
    expect(find.byType(SliverList), findsNothing);
  });

  testWidgets('LumenSliverList aplica padding aos itens e ao empty', (tester) async {
    await pumpBare(
      tester,
      _view(
        LumenSliverList(
          padding: const EdgeInsets.all(20),
          itemCount: 2,
          itemBuilder: (context, i) => Text('item $i'),
        ),
      ),
    );
    final origin = tester.getTopLeft(find.byType(CustomScrollView));
    expect(tester.getTopLeft(find.text('item 0')), origin + const Offset(20, 20));

    await pumpBare(
      tester,
      _view(
        LumenSliverList(
          padding: const EdgeInsets.all(20),
          itemCount: 0,
          empty: const Text('vazio'),
          itemBuilder: (context, i) => Text('item $i'),
        ),
      ),
    );
    expect(
      tester.getTopLeft(find.text('vazio')),
      tester.getTopLeft(find.byType(CustomScrollView)) + const Offset(20, 20),
    );
  });
}
