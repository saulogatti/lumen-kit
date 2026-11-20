import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

BoxDecoration _decorationOf(WidgetTester tester) =>
    tester
            .widget<Container>(
              find.descendant(of: find.byType(LumenSkeleton), matching: find.byType(Container)),
            )
            .decoration!
        as BoxDecoration;

void main() {
  testWidgets('LumenSkeleton retangular ocupa o tamanho pedido com cantos arredondados', (
    tester,
  ) async {
    for (final width in <double>[80, 120]) {
      await pumpBare(tester, LumenSkeleton(width: width, height: 20));
      expect(tester.getSize(find.byType(LumenSkeleton)), Size(width, 20));
      final decoration = _decorationOf(tester);
      expect(decoration.shape, BoxShape.rectangle);
      expect(decoration.borderRadius, isNotNull);
    }
  });

  testWidgets('LumenSkeleton.circle usa o diâmetro na largura e na altura', (tester) async {
    for (final size in <double>[32, 48]) {
      await pumpBare(tester, LumenSkeleton.circle(size: size));
      expect(tester.getSize(find.byType(LumenSkeleton)), Size(size, size));
      final decoration = _decorationOf(tester);
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.borderRadius, isNull);
    }
  });

  testWidgets('LumenSkeleton usa as cores recebidas no lugar da paleta', (tester) async {
    final base = LumenPalette.light().surface;
    await pumpBare(tester, LumenSkeleton(width: 100, baseColor: base));
    expect(_decorationOf(tester).color, base);
  });
}
