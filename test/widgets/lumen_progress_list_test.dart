import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('30 tasks scroll independently of the page and update only their row', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 500);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final sources = List.generate(30, (_) => ValueNotifier<double?>(0));
    addTearDown(() {
      for (final source in sources) {
        source.dispose();
      }
    });
    await pumpBare(
      tester,
      Column(
        children: [
          SizedBox(
            height: 200,
            child: LumenProgressList(
              items: [
                for (var i = 0; i < sources.length; i++)
                  LumenProgressItem(label: 'Task ${i + 1}', progress: sources[i]),
              ],
            ),
          ),
          const Text('Footer'),
        ],
      ),
    );
    expect(tester.getSize(find.byType(ListView)).height, 200);
    final footerPosition = tester.getCenter(find.text('Footer'));
    expect(find.text('Task 30'), findsNothing);
    final neighbor = tester.widget<Text>(find.text('Task 2'));
    sources.first.value = 0.35;
    sources.last.value = 0.82;
    await tester.pump();
    expect(find.text('35%'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Task 2')), same(neighbor));
    await tester.scrollUntilVisible(find.text('Task 30'), 150);
    await tester.pumpAndSettle();
    expect(find.text('82%').hitTestable(), findsOneWidget);
    expect(tester.getCenter(find.text('Footer')), footerPosition);
  });

  testWidgets('unknown progress becomes determinate and exposes the task to semantics', (
    tester,
  ) async {
    final source = ValueNotifier<double?>(null);
    addTearDown(source.dispose);
    await pumpBare(
      tester,
      LumenProgressList(
        items: [LumenProgressItem(label: 'Index records', progress: source)],
      ),
      reduceMotion: true,
    );
    final bar = find.byType(LumenLinearProgress);
    expect(tester.widget<LumenLinearProgress>(bar).value, isNull);
    await tester.pumpAndSettle();
    source.value = 1;
    await tester.pump();
    expect(tester.getSemantics(bar), isSemantics(label: 'Index records', value: '100%'));
  });
}
