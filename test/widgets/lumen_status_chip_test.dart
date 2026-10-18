import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  test('cada LumenStatusTone resolve cor da paleta e ícone próprio', () {
    final p = LumenPalette.defaultDark();
    expect(LumenStatusTone.values.map((t) => t.colorOf(p)), <Color>[
      p.textMuted,
      p.primary,
      p.success,
      p.warning,
      p.danger,
    ]);
    expect(LumenStatusTone.values.map((t) => t.icon).toSet(), hasLength(5));
  });

  testWidgets('LumenStatusChip com icon troca o ponto pelo ícone na cor do tom', (tester) async {
    await pumpBare(
      tester,
      const LumenStatusChip(label: 'Falhou', tone: LumenStatusTone.danger, icon: Icons.error),
    );
    expect(tester.widget<Icon>(find.byIcon(Icons.error)).color, LumenPalette.light().danger);
    expect(find.text('Falhou'), findsOneWidget);
  });
}
