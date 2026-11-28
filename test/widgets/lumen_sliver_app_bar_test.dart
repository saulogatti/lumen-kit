import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

Widget _scroll(Widget appBar, {ScrollController? controller, int items = 40}) => SizedBox(
  width: 320,
  height: 400,
  child: CustomScrollView(
    controller: controller,
    slivers: <Widget>[
      appBar,
      LumenSliverList(
        itemCount: items,
        itemBuilder: (context, i) => SizedBox(height: 50, child: Text('linha $i')),
      ),
    ],
  ),
);

double _opacityOf(WidgetTester tester, Finder text) =>
    tester.widget<Opacity>(find.ancestor(of: text, matching: find.byType(Opacity)).first).opacity;

/// The bar's own box: the sliver itself has no size a finder can read.
final Finder _bar = find.descendant(
  of: find.byType(LumenSliverAppBar),
  matching: find.byType(AnimatedContainer),
);

Color? _background(WidgetTester tester) =>
    (tester.widget<AnimatedContainer>(_bar).decoration as BoxDecoration?)?.color;

void main() {
  testWidgets('LumenSliverAppBar mostra título, subtítulo, leading e a ação', (tester) async {
    var taps = 0;
    await pumpBare(
      tester,
      _scroll(
        LumenSliverAppBar(
          title: 'Painel',
          subtitle: 'agora',
          leading: const Icon(Icons.menu),
          actions: <Widget>[IconButton(onPressed: () => taps++, icon: const Icon(Icons.settings))],
        ),
      ),
    );

    expect(find.text('Painel'), findsOneWidget);
    expect(find.text('agora'), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump();
    expect(taps, 1);
    // 64 de barra + 2 da linha decorativa.
    expect(tester.getSize(_bar).height, 66);
  });

  testWidgets('LumenSliverAppBar fixa permanece no topo e ganha fundo ao rolar', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpBare(tester, _scroll(const LumenSliverAppBar(title: 'Fixa'), controller: controller));
    final top = tester.getTopLeft(find.byType(CustomScrollView)).dy;
    expect(_background(tester)?.a, 0);

    controller.jumpTo(600);
    await tester.pumpAndSettle();

    expect(find.text('Fixa'), findsOneWidget);
    expect(tester.getTopLeft(_bar).dy, top);
    expect(_background(tester)?.a, greaterThan(0.9));
    expect(find.text('linha 0'), findsNothing);
  });

  testWidgets('LumenSliverAppBar não fixa sai da tela e a flutuante volta ao rolar para cima', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpBare(
      tester,
      _scroll(const LumenSliverAppBar(title: 'Solta', pinned: false), controller: controller),
    );
    controller.jumpTo(600);
    await tester.pump();
    expect(find.text('Solta'), findsNothing);

    await pumpBare(
      tester,
      _scroll(
        const LumenSliverAppBar(title: 'Flutua', pinned: false, floating: true),
        controller: controller,
      ),
    );
    controller.jumpTo(600);
    await tester.pump();
    expect(find.text('Flutua'), findsNothing);
    // The bar floats in while the finger is still down: the sliver reads the
    // scroll direction during layout, and it goes idle once the drag ends.
    final gesture = await tester.startGesture(tester.getCenter(find.byType(CustomScrollView)));
    await gesture.moveBy(const Offset(0, 40));
    await gesture.moveBy(const Offset(0, 60));
    await tester.pump();
    expect(find.text('Flutua'), findsOneWidget);
    expect(controller.offset, greaterThan(400));
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('LumenSliverAppBar expandida recolhe o título grande para a barra', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpBare(
      tester,
      _scroll(
        const LumenSliverAppBar(title: 'Pedidos', subtitle: '12 abertos', expandedHeight: 160),
        controller: controller,
      ),
    );

    // Expandida: 160 + 2; o título grande aparece e o da barra some.
    expect(tester.getSize(_bar).height, 162);
    expect(find.text('Pedidos'), findsNWidgets(2));
    expect(_opacityOf(tester, find.text('Pedidos').first), 0);
    expect(_opacityOf(tester, find.text('Pedidos').last), 1);

    controller.jumpTo(48);
    await tester.pump();
    expect(tester.getSize(_bar).height, 114);
    expect(tester.takeException(), isNull);

    controller.jumpTo(300);
    await tester.pump();
    // Recolhida: sobra só a barra, com o título dela visível.
    expect(tester.getSize(_bar).height, 66);
    expect(_opacityOf(tester, find.text('Pedidos').first), 1);
    expect(_opacityOf(tester, find.text('Pedidos').last), 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('LumenSliverAppBar reserva a barra de status só quando primary', (tester) async {
    Widget app({required bool primary}) => MediaQuery(
      data: const MediaQueryData(padding: EdgeInsets.only(top: 30)),
      child: _scroll(LumenSliverAppBar(title: 'Topo', primary: primary, showDivider: false)),
    );

    await pumpBare(tester, app(primary: true));
    final bar = tester.getRect(_bar);
    expect(bar.height, 94);
    expect(tester.getRect(find.text('Topo')).top, greaterThanOrEqualTo(bar.top + 30));

    await pumpBare(tester, app(primary: false));
    expect(tester.getSize(_bar).height, 64);
  });

  testWidgets('LumenSliverAppBar anuncia o título como cabeçalho', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpBare(
      tester,
      _scroll(const LumenSliverAppBar(title: 'Relatórios', expandedHeight: 140)),
    );
    // Só o título visível entra na árvore de semântica.
    expect(find.bySemanticsLabel('Relatórios'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Relatórios')).flagsCollection.isHeader,
      isTrue,
    );
    handle.dispose();
  });

  testWidgets('LumenSliverAppBar troca o fundo sem animar com movimento reduzido', (tester) async {
    await pumpBare(tester, _scroll(const LumenSliverAppBar(title: 'Calma')), reduceMotion: true);
    final container = tester.widget<AnimatedContainer>(
      find.descendant(of: find.byType(LumenSliverAppBar), matching: find.byType(AnimatedContainer)),
    );
    expect(container.duration, Duration.zero);
  });

  testWidgets('LumenSliverAppBar pinta títulos e subtítulos com o texto da paleta do LumenScope', (
    tester,
  ) async {
    // Paleta clara dentro de um app escuro: o texto do tema de fora seria
    // claro sobre o fundo claro da barra.
    final palette = LumenPalette.light();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: Scaffold(
          body: LumenScope(
            palette: palette,
            child: _scroll(
              const LumenSliverAppBar(title: 'Pedidos', subtitle: 'abertos', expandedHeight: 160),
            ),
          ),
        ),
      ),
    );

    Color? color(Finder text) => tester.widget<Text>(text).style?.color;
    // first = barra recolhida, last = título grande.
    expect(color(find.text('Pedidos').first), palette.textPrimary);
    expect(color(find.text('Pedidos').last), palette.textPrimary);
    expect(color(find.text('abertos').first), palette.textMuted);
    expect(color(find.text('abertos').last), palette.textSecondary);
  });

  testWidgets('LumenSliverAppBar segue o LumenScope e some com a linha sem showDivider', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final palette = LumenPalette.fromSeed(primary: const Color(0xFF39FF14));
    await pumpBare(
      tester,
      LumenScope(
        palette: palette,
        style: LumenStyle.glass,
        child: _scroll(
          const LumenSliverAppBar(title: 'Vidro', showDivider: false),
          controller: controller,
        ),
      ),
    );
    expect(tester.getSize(_bar).height, 64);
    expect(
      find.descendant(of: find.byType(LumenSliverAppBar), matching: find.byType(BackdropFilter)),
      findsOneWidget,
    );
    controller.jumpTo(300);
    await tester.pumpAndSettle();
    final color = _background(tester)!;
    expect(color.withValues(alpha: 1), palette.backgroundDeep);
    expect(color.a, moreOrLessEquals(0.92 * LumenStyle.glass.surfaceOpacity, epsilon: 0.01));
  });

  testWidgets('LumenSliverAppBar corta o título grande que não cabe, sem estourar', (tester) async {
    await pumpBare(
      tester,
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _scroll(
          const LumenSliverAppBar(title: 'Pedidos', subtitle: '12 abertos', expandedHeight: 100),
        ),
      ),
    );
    expect(tester.getSize(_bar).height, 102);
  });

  test('LumenSliverAppBar recusa alturas inválidas', () {
    expect(() => LumenSliverAppBar(title: 'x', height: 0), throwsAssertionError);
    expect(() => LumenSliverAppBar(title: 'x', expandedHeight: 40), throwsAssertionError);
  });
}
