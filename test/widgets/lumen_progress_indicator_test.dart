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
