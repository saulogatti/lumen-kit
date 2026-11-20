import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

Widget _field({
  required Color? value,
  required ValueChanged<Color>? onChanged,
  bool showAlpha = false,
  String alphaLabel = 'Opacity',
  String? hint,
  Color? accentColor,
}) => SizedBox(
  width: 320,
  child: LumenColorField(
    label: 'Accent',
    hint: hint,
    value: value,
    accentColor: accentColor,
    showAlpha: showAlpha,
    alphaLabel: alphaLabel,
    onChanged: onChanged,
  ),
);

String _hexText(WidgetTester tester) =>
    tester.widget<EditableText>(find.byType(EditableText)).controller.text;

void main() {
  testWidgets('LumenColorField sem tema mostra a amostra e o hex', (tester) async {
    await pumpBare(tester, _field(value: const Color(0xFF00BCD4), onChanged: (_) {}));
    expect(find.text('Accent'), findsOneWidget);
    expect(find.text('#00BCD4'), findsOneWidget);
    expect(find.byIcon(Icons.palette_outlined), findsNothing);
    expect(
      tester.getSemantics(find.byType(LumenColorField)),
      isSemantics(label: 'Accent\n#00BCD4', isButton: true, isEnabled: true, hasTapAction: true),
    );
  });

  testWidgets('cor translúcida mostra o hex de 8 dígitos sobre o xadrez', (tester) async {
    await pumpBare(tester, _field(value: const Color(0x8000BCD4), onChanged: (_) {}));
    expect(find.text('#8000BCD4'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is CustomPaint && '${widget.painter.runtimeType}' == '_CheckerPainter',
      ),
      findsOneWidget,
    );
  });

  testWidgets('tocar abre o picker na cor atual e OK chama onChanged', (tester) async {
    final picked = <Color>[];
    await pumpBare(tester, _field(value: const Color(0xFF00BCD4), onChanged: picked.add));

    await tester.tap(find.byType(LumenColorField));
    await tester.pumpAndSettle();
    expect(find.text('Hex'), findsOneWidget);
    expect(_hexText(tester), '#00BCD4');
    expect(find.bySemanticsLabel('Opacity'), findsNothing);

    await tester.enterText(find.byType(EditableText), '#FF0000');
    await tester.pump();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Hex'), findsNothing);
    expect(picked.map((c) => c.toARGB32()), <int>[0xFFFF0000]);
  });

  testWidgets('Cancel fecha o picker sem chamar onChanged', (tester) async {
    final picked = <Color>[];
    await pumpBare(tester, _field(value: const Color(0xFF00BCD4), onChanged: picked.add));

    await tester.tap(find.byType(LumenColorField));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), '#FF0000');
    await tester.pump();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Hex'), findsNothing);
    expect(picked, isEmpty);
  });

  testWidgets('sem valor mostra o hint e abre na cor de destaque', (tester) async {
    const accent = Color(0xFFFF4081);
    await pumpBare(
      tester,
      _field(value: null, hint: 'Pick one', accentColor: accent, onChanged: (_) {}),
    );
    expect(find.text('Pick one'), findsOneWidget);
    expect(find.byIcon(Icons.palette_outlined), findsOneWidget);

    await tester.tap(find.byType(LumenColorField));
    await tester.pumpAndSettle();
    expect(_hexText(tester), '#FF4081');
  });

  testWidgets('showAlpha e rótulos chegam ao picker', (tester) async {
    final picked = <Color>[];
    await pumpBare(
      tester,
      _field(
        value: const Color(0xFF00BCD4),
        showAlpha: true,
        alphaLabel: 'Alpha',
        onChanged: picked.add,
      ),
    );

    await tester.tap(find.byType(LumenColorField));
    await tester.pumpAndSettle();
    final track = tester.getRect(find.bySemanticsLabel('Alpha'));
    await tester.tapAt(Offset(track.left + track.width / 2, track.center.dy));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(picked.single.toARGB32(), 0x8000BCD4);
  });

  testWidgets('LumenColorField desabilitado não abre o picker', (tester) async {
    await pumpBare(tester, _field(value: const Color(0xFF00BCD4), onChanged: null));

    expect(
      find.descendant(of: find.byType(LumenColorField), matching: find.byType(Opacity)),
      findsOneWidget,
    );
    expect(
      tester.getSemantics(find.byType(LumenColorField)),
      isSemantics(isButton: true, hasEnabledState: true, isEnabled: false),
    );
    await tester.tap(find.byType(LumenColorField));
    await tester.pumpAndSettle();
    expect(find.text('Hex'), findsNothing);
  });
}
