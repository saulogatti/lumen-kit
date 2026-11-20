import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('entrance animates once and preserves its child on rebuild', (tester) async {
    // Non-const, so each pump hands the state a new widget (didUpdateWidget).
    Widget entrance(String label) => LumenEntrance(
      duration: const Duration(seconds: 1),
      curve: Curves.linear,
      child: Text(label),
    );
    await pumpBare(tester, entrance('Hello'));
    final opacity = find.descendant(of: find.byType(LumenEntrance), matching: find.byType(Opacity));
    expect(tester.widget<Opacity>(opacity).opacity, 0);
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.widget<Opacity>(opacity).opacity, closeTo(0.5, 0.01));
    await tester.pumpAndSettle();
    await pumpBare(tester, entrance('Hello again'));
    expect(tester.widget<Opacity>(opacity).opacity, 1);
    expect(find.text('Hello again'), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('rebuilding with a zero duration finishes an active entrance', (tester) async {
    Widget entrance(Duration duration) =>
        LumenEntrance(duration: duration, child: const Text('Hi'));
    await pumpBare(tester, entrance(const Duration(seconds: 1)));
    await tester.pump(const Duration(milliseconds: 100));
    await pumpBare(tester, entrance(Duration.zero));
    final opacity = find.descendant(of: find.byType(LumenEntrance), matching: find.byType(Opacity));
    expect(tester.widget<Opacity>(opacity).opacity, 1);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('switcher removes outgoing semantics and pointer actions', (tester) async {
    final semantics = tester.ensureSemantics();
    var presses = 0;
    Widget content(String label) => LumenAnimatedSwitcher(
      duration: const Duration(seconds: 1),
      child: TextButton(
        key: ValueKey<String>(label),
        onPressed: () => presses++,
        child: Text(label),
      ),
    );
    await pumpBare(tester, content('Old'));
    await pumpBare(tester, content('New'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Old'), findsOneWidget);
    expect(find.bySemanticsLabel('Old'), findsNothing);
    expect(find.bySemanticsLabel('New'), findsOneWidget);
    await tester.tap(find.text('New'));
    expect(presses, 1);
    await tester.pumpAndSettle();
    expect(find.text('Old'), findsNothing);
    semantics.dispose();
  });

  testWidgets('reduced motion skips entrance and outgoing content', (tester) async {
    await pumpBare(tester, const LumenEntrance(child: Text('Visible')), reduceMotion: true);
    final opacity = find.descendant(of: find.byType(LumenEntrance), matching: find.byType(Opacity));
    expect(tester.widget<Opacity>(opacity).opacity, 1);
    for (final label in <String>['Old', 'New']) {
      await pumpBare(
        tester,
        LumenAnimatedSwitcher(child: Text(label, key: ValueKey<String>(label))),
        reduceMotion: true,
      );
    }
    expect(find.text('Old'), findsNothing);
    expect(find.text('New'), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('enabling reduced motion finishes an active entrance', (tester) async {
    const Widget entrance = LumenEntrance(duration: Duration(seconds: 1), child: Text('Visible'));
    await pumpBare(tester, entrance);
    await tester.pump(const Duration(milliseconds: 100));
    await pumpBare(tester, entrance, reduceMotion: true);
    await tester.pump();
    final opacity = find.descendant(of: find.byType(LumenEntrance), matching: find.byType(Opacity));
    expect(tester.widget<Opacity>(opacity).opacity, 1);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('new entrance key replays the transition', (tester) async {
    for (final version in <int>[0, 1]) {
      await pumpBare(
        tester,
        LumenEntrance(key: ValueKey<int>(version), child: const Text('Replay')),
      );
      final opacity = find.descendant(
        of: find.byType(LumenEntrance),
        matching: find.byType(Opacity),
      );
      expect(tester.widget<Opacity>(opacity).opacity, 0);
      await tester.pumpAndSettle();
      expect(tester.widget<Opacity>(opacity).opacity, 1);
    }
  });

  testWidgets('reduced motion removes an active outgoing child', (tester) async {
    Widget content(String label) => LumenAnimatedSwitcher(
      duration: const Duration(seconds: 1),
      child: Text(label, key: ValueKey<String>(label)),
    );
    await pumpBare(tester, content('Old'));
    await pumpBare(tester, content('New'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Old'), findsOneWidget);
    await pumpBare(tester, content('New'), reduceMotion: true);
    expect(find.text('Old'), findsNothing);
    expect(find.text('New'), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
