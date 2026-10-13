import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:lumen_kit_example/main.dart';

void main() {
  testWidgets('galeria renderiza inteira sem exceção', (WidgetTester t) async {
    t.view.physicalSize = const Size(420, 900);
    t.view.devicePixelRatio = 1;
    await t.pumpWidget(const LumenExampleApp());
    await t.pump(const Duration(milliseconds: 500));
    for (int i = 0; i < 40; i++) {
      await t.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await t.pump(const Duration(milliseconds: 100));
      expect(t.takeException(), isNull);
    }
  });
}
