// Fundações e fundo implementam debugFillProperties para o inspector do
// DevTools; isto garante que as props públicas aparecem no dump.
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import 'widgets/_harness.dart';

void main() {
  test('LumenActionContent e LumenLabeled listam as props no diagnóstico', () {
    final action = const LumenActionContent(
      color: Color(0xFF00E5FF),
      label: 'Salvar',
      icon: Icons.save,
      busy: true,
    ).toStringDeep();
    expect(action, contains('label: "Salvar"'));
    expect(action, contains('busy: true'));
    expect(action, contains('spinnerSize: 16.0'));

    final labeled = const LumenLabeled(
      control: SizedBox(),
      label: 'Aceito',
      enabled: false,
    ).toStringDeep();
    expect(labeled, contains('label: "Aceito"'));
    expect(labeled, contains('enabled: false'));
  });

  testWidgets('LumenAnimatedGridBackground lista grade e orbs no diagnóstico', (tester) async {
    await pumpBare(
      tester,
      const SizedBox(
        width: 200,
        height: 200,
        child: LumenAnimatedGridBackground(
          gridSpacing: 40,
          orbs: <LumenGlowOrbSpec>[LumenGlowOrbSpec(color: Color(0xFFE91E63), size: 80)],
          child: SizedBox(),
        ),
      ),
    );
    final dump = tester.element(find.byType(LumenAnimatedGridBackground)).toStringDeep();
    expect(dump, contains('gridSpacing: 40.0'));
    expect(dump, contains('showGrid: true'));
    expect(dump, contains('spec:'));
  });

  testWidgets('a grade só repinta quando espaçamento ou cor mudam', (tester) async {
    Widget grid(double spacing) => bareApp(
      SizedBox(
        width: 200,
        height: 200,
        child: LumenAnimatedGridBackground(gridSpacing: spacing, child: const SizedBox()),
      ),
    );
    CustomPainter painter() => tester
        .widget<CustomPaint>(
          find
              .descendant(
                of: find.byType(LumenAnimatedGridBackground),
                matching: find.byType(CustomPaint),
              )
              .first,
        )
        .painter!;

    await tester.pumpWidget(grid(56));
    final first = painter();
    await tester.pumpWidget(grid(56));
    expect(painter().shouldRepaint(first), isFalse);

    await tester.pumpWidget(grid(32));
    expect(painter().shouldRepaint(first), isTrue);
  });
}
