import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  Size backgroundSize(WidgetTester tester) =>
      tester.getSize(find.byType(LumenAnimatedGridBackground));

  testWidgets('com limites ocupa todo o espaço, mesmo com filho pequeno', (tester) async {
    await pumpBare(
      tester,
      const SizedBox(width: 300, height: 200, child: LumenAnimatedGridBackground(child: Text('a'))),
    );
    expect(backgroundSize(tester), const Size(300, 200));
    // The child gets the full extent, as with the old Positioned.fill.
    expect(tester.getSize(find.text('a')).width, 300);
  });

  final unbounded = <String, Widget Function(Widget)>{
    'Column': (w) => Column(children: <Widget>[w]),
    'Row': (w) => Row(children: <Widget>[w]),
    'ListView': (w) => ListView(children: <Widget>[w]),
    'SingleChildScrollView': (w) => SingleChildScrollView(child: w),
  };
  for (final entry in unbounded.entries) {
    testWidgets('dentro de ${entry.key} o filho define o tamanho sem erro', (tester) async {
      await pumpBare(
        tester,
        entry.value(const LumenAnimatedGridBackground(child: SizedBox(width: 120, height: 80))),
      );
      final size = backgroundSize(tester);
      expect(size.isFinite, isTrue);
      // In the unbounded axis the background matches the child.
      if (entry.key == 'Row') {
        expect(size.width, 120);
      } else {
        expect(size.height, 80);
      }
    });
  }

  testWidgets('mede a altura intrínseca pelo filho', (tester) async {
    await pumpBare(
      tester,
      const IntrinsicHeight(
        child: LumenAnimatedGridBackground(child: SizedBox(width: 50, height: 64)),
      ),
    );
    expect(backgroundSize(tester).height, 64);
  });

  testWidgets('layout seco segue as mesmas regras', (tester) async {
    await pumpBare(
      tester,
      const LumenAnimatedGridBackground(child: SizedBox(width: 40, height: 30)),
    );
    final box = tester.renderObject<RenderBox>(find.byType(SizedBox).last).parent! as RenderBox;
    expect(
      box.getDryLayout(const BoxConstraints(maxWidth: 200, maxHeight: 100)),
      const Size(200, 100),
    );
    expect(box.getDryLayout(const BoxConstraints(maxWidth: 200)), const Size(200, 30));
  });

  test('valores inválidos são recusados em debug', () {
    expect(
      () => LumenAnimatedGridBackground(gridSpacing: 0, child: const SizedBox()),
      throwsAssertionError,
    );
    expect(
      () => LumenAnimatedGridBackground(gridOpacity: 1.5, child: const SizedBox()),
      throwsAssertionError,
    );
    expect(() => LumenGlowOrbSpec(color: Colors.red, size: -1), throwsAssertionError);
    expect(() => LumenGlowOrbSpec(color: Colors.red, size: 10, opacity: 2), throwsAssertionError);
  });
}
