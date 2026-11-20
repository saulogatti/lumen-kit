import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenCircularProgress para o loop ao virar determinado', (tester) async {
    await tester.pumpWidget(bareApp(const LumenCircularProgress()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(bareApp(const LumenCircularProgress(value: 0.4)));
    // Se o loop continuasse, pumpAndSettle estouraria o tempo.
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(bareApp(const LumenCircularProgress()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue);
  });

  group('brilho do LumenCircularProgress', () {
    Finder arc() =>
        find.descendant(of: find.byType(LumenCircularProgress), matching: find.byType(CustomPaint));

    // Glow arcs are the blurred ones; the arc itself has no mask filter.
    bool glowArc(Symbol method, List<dynamic> args, bool Function(Paint) check) {
      if (method != #drawArc) return false;
      final paint = args[4] as Paint;
      return paint.maskFilter != null && check(paint);
    }

    testWidgets('glowColor pinta o brilho com a cor dada', (tester) async {
      const red = Color(0xFFFF0000);
      await pumpBare(tester, const LumenCircularProgress(value: 0.5, glowColor: red));
      expect(
        arc(),
        paints
          ..circle()
          ..something((m, a) => glowArc(m, a, (p) => p.color == red && p.shader == null))
          ..arc(hasMaskFilter: false),
      );
    });

    testWidgets('sem glowColor o brilho segue o gradiente do arco', (tester) async {
      await pumpBare(tester, const LumenCircularProgress(value: 0.5));
      expect(
        arc(),
        paints
          ..circle()
          ..something((m, a) => glowArc(m, a, (p) => p.shader != null))
          ..arc(hasMaskFilter: false),
      );
    });

    testWidgets('trocar o glowColor atualiza o brilho', (tester) async {
      await pumpBare(tester, const LumenCircularProgress(value: 0.5));
      await pumpBare(tester, const LumenCircularProgress(value: 0.5, glowColor: Color(0xFF00FF00)));
      expect(
        arc(),
        paints
          ..circle()
          ..something((m, a) => glowArc(m, a, (p) => p.color == const Color(0xFF00FF00))),
      );
    });
  });

  testWidgets('LumenLinearProgress preenche a fração do valor, limitada a 1', (tester) async {
    for (final value in <double>[0.25, 1.5]) {
      await pumpBare(tester, SizedBox(width: 200, child: LumenLinearProgress(value: value)));
      final bar = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(bar.widthFactor, value.clamp(0.0, 1.0));
    }
  });

  testWidgets('LumenLinearProgress desenha a parte preenchida e acompanha o valor', (tester) async {
    final filled = find.descendant(
      of: find.byType(FractionallySizedBox),
      matching: find.byType(DecoratedBox),
    );
    for (final value in <double>[0, 0.3, 0.75, 1]) {
      await pumpBare(
        tester,
        SizedBox(width: 200, child: LumenLinearProgress(value: value, height: 8)),
      );
      expect(tester.getSize(filled), Size(200 * value, 8), reason: 'value $value');
    }
  });

  testWidgets('LumenLinearProgress preenche a partir do início no RTL', (tester) async {
    await pumpBare(
      tester,
      const Directionality(
        textDirection: TextDirection.rtl,
        child: SizedBox(width: 200, child: LumenLinearProgress(value: 0.25)),
      ),
    );
    final track = tester.getRect(find.byType(LumenLinearProgress));
    final filled = tester.getRect(
      find.descendant(of: find.byType(FractionallySizedBox), matching: find.byType(DecoratedBox)),
    );
    expect(filled.right, track.right);
    expect(filled.width, 50);
  });
}
