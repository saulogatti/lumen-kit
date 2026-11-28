import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

double _opacity(WidgetTester tester, String title) => tester
    .widget<Opacity>(
      find
          .descendant(of: find.widgetWithText(LumenGridTile, title), matching: find.byType(Opacity))
          .first,
    )
    .opacity;

BoxDecoration _decoration(WidgetTester tester, String title) =>
    tester
            .widget<AnimatedContainer>(
              find.descendant(
                of: find.widgetWithText(LumenGridTile, title),
                matching: find.byType(AnimatedContainer),
              ),
            )
            .decoration!
        as BoxDecoration;

void main() {
  testWidgets('LumenGridTile empilha leading, título e subtítulo na vertical', (tester) async {
    await pumpBare(
      tester,
      const SizedBox(
        width: 160,
        height: 160,
        child: LumenGridTile(
          title: 'Pedidos',
          subtitle: '12 abertos',
          leading: Icon(Icons.receipt_long_outlined),
        ),
      ),
    );

    final icon = tester.getRect(find.byIcon(Icons.receipt_long_outlined));
    final title = tester.getRect(find.text('Pedidos'));
    final subtitle = tester.getRect(find.text('12 abertos'));
    expect(icon.bottom, lessThanOrEqualTo(title.top));
    expect(title.bottom, lessThanOrEqualTo(subtitle.top));
    // Centralizado por padrão.
    expect(icon.center.dx, moreOrLessEquals(title.center.dx, epsilon: 0.5));
    expect(tester.widget<Text>(find.text('Pedidos')).textAlign, TextAlign.center);
    // O tile ocupa a célula inteira.
    expect(tester.getSize(find.byType(LumenGridTile)), const Size(160, 160));
  });

  testWidgets('LumenGridTile alinha ao início ou ao fim com crossAxisAlignment', (tester) async {
    await pumpBare(
      tester,
      const SizedBox(
        width: 320,
        height: 120,
        child: Row(
          children: <Widget>[
            Expanded(
              child: LumenGridTile(title: 'Início', crossAxisAlignment: CrossAxisAlignment.start),
            ),
            Expanded(
              child: LumenGridTile(title: 'Fim', crossAxisAlignment: CrossAxisAlignment.end),
            ),
          ],
        ),
      ),
    );
    expect(tester.widget<Text>(find.text('Início')).textAlign, TextAlign.start);
    expect(tester.widget<Text>(find.text('Fim')).textAlign, TextAlign.end);
  });

  testWidgets('LumenGridTile dispara onTap e onLongPress', (tester) async {
    var taps = 0;
    var longPresses = 0;
    await pumpBare(
      tester,
      SizedBox(
        width: 140,
        height: 140,
        child: LumenGridTile(title: 'Ação', onTap: () => taps++, onLongPress: () => longPresses++),
      ),
    );
    await tester.tap(find.text('Ação'));
    await tester.longPress(find.text('Ação'));
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(longPresses, 1);
  });

  testWidgets('LumenGridTile sem ação apaga a 0.7; selecionado ou com ação fica inteiro', (
    tester,
  ) async {
    await pumpBare(
      tester,
      SizedBox(
        width: 360,
        height: 120,
        child: Row(
          children: <Widget>[
            const Expanded(child: LumenGridTile(title: 'Info')),
            const Expanded(child: LumenGridTile(title: 'Atual', selected: true)),
            Expanded(
              child: LumenGridTile(title: 'Ação', onTap: () {}),
            ),
          ],
        ),
      ),
    );
    expect(_opacity(tester, 'Info'), 0.7);
    expect(_opacity(tester, 'Atual'), 1);
    expect(_opacity(tester, 'Ação'), 1);
  });

  testWidgets('LumenGridTile selecionado usa accentColor na borda, no brilho e no ícone', (
    tester,
  ) async {
    const accent = Color(0xFFFF8A00);
    await pumpBare(
      tester,
      SizedBox(
        width: 320,
        height: 140,
        child: Row(
          children: <Widget>[
            Expanded(
              child: LumenGridTile(
                title: 'Marcado',
                leading: const Icon(Icons.star),
                selected: true,
                accentColor: accent,
                onTap: () {},
              ),
            ),
            Expanded(
              child: LumenGridTile(title: 'Normal', onTap: () {}),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final selected = _decoration(tester, 'Marcado');
    expect(selected.color, accent.withValues(alpha: 0.14));
    expect(selected.boxShadow, isNotNull);
    expect((selected.border! as Border).top.color, accent.withValues(alpha: 0.6));
    expect(_decoration(tester, 'Normal').boxShadow, isNull);

    final icon = tester.renderObject<RenderParagraph>(
      find.descendant(of: find.byIcon(Icons.star), matching: find.byType(RichText)),
    );
    expect(icon.text.style?.color, accent);
  });

  testWidgets('LumenGridTile anuncia botão e seleção ao leitor de tela', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpBare(
      tester,
      SizedBox(
        width: 320,
        height: 140,
        child: Row(
          children: <Widget>[
            Expanded(
              child: LumenGridTile(
                title: 'Pedidos',
                subtitle: '12 abertos',
                selected: true,
                onTap: () {},
              ),
            ),
            const Expanded(child: LumenGridTile(title: 'Leitura')),
          ],
        ),
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp('Pedidos'))),
      isSemantics(
        label: 'Pedidos\n12 abertos',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    final info = tester.getSemantics(find.bySemanticsLabel('Leitura'));
    expect(info.flagsCollection.isButton, isFalse);
    handle.dispose();
  });

  testWidgets('LumenGridTile corta texto longo com reticências sem estourar a célula', (
    tester,
  ) async {
    await pumpBare(
      tester,
      const SizedBox(
        width: 90,
        height: 90,
        child: LumenGridTile(
          title: 'Um título comprido demais para caber em uma célula pequena da grade',
          subtitle: 'E um subtítulo igualmente longo que também precisa ser cortado',
          leading: Icon(Icons.inventory_2_outlined),
          titleMaxLines: 1,
          subtitleMaxLines: 1,
        ),
      ),
    );
    final title = tester.widget<Text>(find.textContaining('Um título'));
    expect(title.maxLines, 1);
    expect(title.overflow, TextOverflow.ellipsis);
  });

  testWidgets('LumenGridTile não anima a seleção com movimento reduzido', (tester) async {
    await pumpBare(
      tester,
      const SizedBox(width: 140, height: 140, child: LumenGridTile(title: 'Calmo')),
      reduceMotion: true,
    );
    final container = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
    expect(container.duration, Duration.zero);
  });

  testWidgets('LumenGridTile segue a paleta e o estilo do LumenScope', (tester) async {
    final palette = LumenPalette.fromSeed(primary: const Color(0xFF39FF14));
    await pumpBare(
      tester,
      LumenScope(
        palette: palette,
        style: LumenStyle.brutal,
        child: const SizedBox(
          width: 140,
          height: 140,
          child: LumenGridTile(title: 'Escopo', selected: true),
        ),
      ),
    );
    final decoration = _decoration(tester, 'Escopo');
    expect(decoration.color, palette.primary.withValues(alpha: 0.14));
    expect(decoration.borderRadius, BorderRadius.zero);
  });

  test('LumenGridTile recusa limite de linhas não positivo', () {
    expect(() => LumenGridTile(title: 'x', titleMaxLines: 0), throwsAssertionError);
    expect(() => LumenGridTile(title: 'x', subtitleMaxLines: 0), throwsAssertionError);
  });
}
