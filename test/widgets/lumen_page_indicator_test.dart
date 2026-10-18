import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

double _width(WidgetTester tester, int i) =>
    tester.getSize(find.byType(AnimatedContainer).at(i)).width;

void main() {
  testWidgets('LumenPageIndicator alarga o ponto do index e anuncia a página', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpBare(tester, const LumenPageIndicator(count: 4, index: 2));
    await tester.pumpAndSettle();

    expect(find.byType(AnimatedContainer), findsNWidgets(4));
    expect(_width(tester, 2), 24);
    expect(_width(tester, 0), 8);
    expect(find.bySemanticsLabel('3/4'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('LumenPageIndicator segue o PageController e toque troca página', (tester) async {
    final pages = PageController();
    addTearDown(pages.dispose);
    await pumpBare(
      tester,
      SizedBox(
        width: 300,
        height: 300,
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageView(
                controller: pages,
                children: const <Widget>[Text('A'), Text('B'), Text('C')],
              ),
            ),
            LumenPageIndicator(count: 3, controller: pages, onDotTapped: pages.jumpToPage),
          ],
        ),
      ),
    );
    expect(_width(tester, 0), 24);

    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(find.text('B'), findsOneWidget);
    expect(_width(tester, 1), 24);
    expect(_width(tester, 0), 8);

    await tester.tap(find.byType(AnimatedContainer).at(2));
    await tester.pumpAndSettle();
    expect(find.text('C'), findsOneWidget);
    expect(_width(tester, 2), 24);
  });

  testWidgets('LumenCarousel troca de página pelos pontos e avisa', (tester) async {
    final changes = <int>[];
    await pumpBare(
      tester,
      SizedBox(
        width: 360,
        child: LumenCarousel(
          itemCount: 3,
          height: 160,
          onPageChanged: changes.add,
          itemBuilder: (context, i) => Text('foto $i'),
        ),
      ),
    );

    expect(find.byType(LumenPageIndicator), findsOneWidget);
    await tester.tap(find.byType(AnimatedContainer).at(2));
    await tester.pumpAndSettle();
    expect(changes.last, 2);

    await tester.drag(find.byType(PageView), const Offset(400, 0));
    await tester.pumpAndSettle();
    expect(changes.last, 1);
  });

  testWidgets('LumenCarousel troca de controller sem quebrar', (tester) async {
    final external = PageController();
    addTearDown(external.dispose);
    Widget build(PageController? c) => bareApp(
      SizedBox(
        width: 360,
        child: LumenCarousel(
          controller: c,
          itemCount: 3,
          itemBuilder: (context, i) => Text('foto $i'),
        ),
      ),
    );
    await tester.pumpWidget(build(null));
    await tester.pumpWidget(build(external));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(external.hasClients, isTrue);

    // Volta ao controller interno, que é criado de novo.
    await tester.pumpWidget(build(null));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(external.hasClients, isFalse);
  });

  testWidgets('LumenCarousel pula direto com "reduzir animações"', (tester) async {
    final changes = <int>[];
    await pumpBare(
      tester,
      SizedBox(
        width: 360,
        child: LumenCarousel(
          itemCount: 3,
          onPageChanged: changes.add,
          itemBuilder: (context, i) => Text('foto $i'),
        ),
      ),
      reduceMotion: true,
    );
    await tester.tap(find.byType(AnimatedContainer).at(2));
    await tester.pump();
    // Um frame só: animateToPage ainda estaria no meio do caminho.
    expect(tester.widget<PageView>(find.byType(PageView)).controller!.page, 2);
    expect(changes, <int>[2]);
  });

  testWidgets('LumenCarousel mantém a página ao mudar viewportFraction', (tester) async {
    Widget build(double fraction) => bareApp(
      SizedBox(
        width: 360,
        child: LumenCarousel(
          itemCount: 3,
          viewportFraction: fraction,
          itemBuilder: (context, i) => Text('foto $i'),
        ),
      ),
      reduceMotion: true,
    );
    await tester.pumpWidget(build(0.88));
    await tester.tap(find.byType(AnimatedContainer).at(2));
    await tester.pump();

    await tester.pumpWidget(build(1));
    await tester.pump(); // descarta o controller antigo no pós-frame
    expect(tester.takeException(), isNull);
    final controller = tester.widget<PageView>(find.byType(PageView)).controller!;
    expect(controller.viewportFraction, 1);
    expect(controller.page, 2);
  });
}
