import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:lumen_kit_example/sections/stepper_section.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('stepper directions keep independent progress and reset', (
    tester,
  ) async {
    await _pumpSection(tester);
    final horizontal = find.byKey(const ValueKey<String>('horizontal-stepper'));
    final vertical = find.byKey(const ValueKey<String>('vertical-stepper'));
    int currentStep(Finder finder) =>
        tester.widget<LumenStepper>(finder).currentStep;
    Finder step(Finder stepper, String title) =>
        find.descendant(of: stepper, matching: find.text(title));

    expect(currentStep(horizontal), 1);
    expect(currentStep(vertical), 1);

    await tester.tap(step(horizontal, 'Done'));
    await tester.pump();
    expect(currentStep(horizontal), 2);
    expect(currentStep(vertical), 1);
    expect(
      find.descendant(
        of: horizontal,
        matching: find.byIcon(Icons.check_rounded),
      ),
      findsNWidgets(2),
    );

    await tester.tap(step(vertical, 'Done'));
    await tester.pump();
    expect(currentStep(horizontal), 2);
    expect(currentStep(vertical), 2);

    await tester.tap(find.text('Reset horizontal'));
    await tester.pump();
    expect(currentStep(horizontal), 0);
    expect(currentStep(vertical), 2);

    await tester.tap(find.text('Reset vertical'));
    await tester.pump();
    expect(currentStep(horizontal), 0);
    expect(currentStep(vertical), 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('vertical stepper expands only the active content', (
    tester,
  ) async {
    await _pumpSection(tester);
    const account = 'Choose an email address and a secure password.';
    const profile = 'Add your name and choose a profile picture.';
    const done = 'Your account is ready. Review your details to finish.';
    final vertical = find.byKey(const ValueKey<String>('vertical-stepper'));

    expect(find.text(profile), findsOneWidget);
    expect(find.text(account), findsNothing);
    expect(find.text(done), findsNothing);

    await tester.tap(
      find.descendant(of: vertical, matching: find.text('Account')),
    );
    await tester.pump();
    expect(find.text(account), findsOneWidget);
    expect(find.text(profile), findsNothing);

    await tester.tap(
      find.descendant(of: vertical, matching: find.text('Done')),
    );
    await tester.pump();
    expect(find.text(done), findsOneWidget);
    expect(find.text(account), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stepper progress survives scrolling outside the list cache', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            controller: controller,
            scrollCacheExtent: const ScrollCacheExtent.pixels(0),
            padding: const EdgeInsets.all(20),
            children: const <Widget>[
              StepperSection(),
              SizedBox(height: 3000),
              Text('End of examples'),
            ],
          ),
        ),
      ),
    );
    final horizontal = find.byKey(const ValueKey<String>('horizontal-stepper'));
    final vertical = find.byKey(const ValueKey<String>('vertical-stepper'));
    await tester.tap(
      find.descendant(of: horizontal, matching: find.text('Done')),
    );
    await tester.tap(find.text('Reset vertical'));
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('End of examples'), 500);
    await tester.pumpAndSettle();
    expect(controller.offset, greaterThan(2000));
    controller.jumpTo(0);
    await tester.pump();

    expect(tester.widget<LumenStepper>(horizontal).currentStep, 2);
    expect(tester.widget<LumenStepper>(vertical).currentStep, 0);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpSection(WidgetTester tester) async {
  tester.view.physicalSize = const Size(420, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: StepperSection(),
        ),
      ),
    ),
  );
}
