import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:lumen_kit_example/sections/control_states_section.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pumpSection(WidgetTester tester) async {
  tester.view.physicalSize = const Size(420, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: ControlStatesSection(),
        ),
      ),
    ),
  );
}

Future<void> _show(WidgetTester tester, Finder finder) async {
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pump(const Duration(milliseconds: 300));
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('actions and selection controls honor their enabled state', (
    tester,
  ) async {
    await _pumpSection(tester);
    await tester.tap(find.text('Run action'));
    await tester.pump();
    expect(find.text('Actions completed: 1'), findsOneWidget);
    await tester.tap(find.text('Disabled action'));
    await tester.tap(find.text('Working'));
    await tester.pump();
    expect(find.text('Actions completed: 1'), findsOneWidget);

    expect(find.text('Checkbox: indeterminate'), findsOneWidget);
    await tester.tap(find.text('Three-state checkbox'));
    await tester.pump();
    expect(find.text('Checkbox: unchecked'), findsOneWidget);
    await tester.tap(find.text('Disabled checkbox'));
    await tester.pump();
    expect(
      tester
          .widget<LumenCheckbox>(
            find.widgetWithText(LumenCheckbox, 'Disabled checkbox'),
          )
          .value,
      isTrue,
    );

    await tester.tap(find.text('Secondary option'));
    await tester.pump();
    await tester.tap(find.text('Disabled option'));
    await tester.pump();
    expect(
      tester
          .widget<LumenRadio<String>>(
            find.widgetWithText(LumenRadio<String>, 'Secondary option'),
          )
          .groupValue,
      'secondary',
    );
    await tester.tap(find.text('Live notifications'));
    await tester.pump();
    await tester.tap(find.text('Disabled notifications'));
    await tester.pump();
    expect(
      tester
          .widget<LumenSwitch>(
            find.widgetWithText(LumenSwitch, 'Live notifications'),
          )
          .value,
      isFalse,
    );
    expect(
      tester
          .widget<LumenSwitch>(
            find.widgetWithText(LumenSwitch, 'Disabled notifications'),
          )
          .value,
      isFalse,
    );
  });

  testWidgets(
    'project validation changes from error to success and clears on edit',
    (tester) async {
      await _pumpSection(tester);
      final validate = find.text('Validate project');
      await _show(tester, validate);
      await tester.tap(validate);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Use at least three characters.'), findsOneWidget);

      final field = find.descendant(
        of: find.byKey(const ValueKey('state-project-name')),
        matching: find.byType(EditableText),
      );
      await _show(tester, field);
      await tester.enterText(field, 'Telemetry');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump(const Duration(milliseconds: 300));
      await _show(tester, validate);
      await tester.tap(validate);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Use at least three characters.'), findsNothing);
      expect(find.text('Project is valid.'), findsOneWidget);
      await _show(tester, field);
      await tester.enterText(field, 'T');
      await tester.pump();
      expect(find.text('Project is valid.'), findsNothing);
    },
  );

  testWidgets(
    'dropdown selection clears the error and disabled inputs remain blocked',
    (tester) async {
      await _pumpSection(tester);
      final required = find.widgetWithText(
        LumenDropdown<String>,
        'Required accent',
      );
      await _show(tester, required);
      await tester.tap(required);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Secondary').last);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Choose an accent to clear this error.'), findsNothing);
      expect(tester.widget<LumenDropdown<String>>(required).value, 'secondary');

      final disabledDropdown = find.widgetWithText(
        LumenDropdown<String>,
        'Disabled accent',
      );
      await _show(tester, disabledDropdown);
      await tester.tapAt(tester.getCenter(find.text('Disabled accent')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        tester.widget<LumenDropdown<String>>(disabledDropdown).value,
        'primary',
      );
      expect(
        tester.widget<LumenDropdown<String>>(disabledDropdown).onChanged,
        isNull,
      );

      final pin = find.byType(LumenPinField);
      await _show(tester, pin);
      await tester.tapAt(tester.getCenter(pin));
      await tester.pump();
      final pinEditable = tester.widget<EditableText>(
        find.descendant(of: pin, matching: find.byType(EditableText)),
      );
      expect(pinEditable.focusNode.hasFocus, isFalse);
      expect(pinEditable.controller.text, '123456');

      final slider = find.byType(Slider);
      await _show(tester, slider);
      await tester.drag(slider, const Offset(100, 0));
      await tester.pump();
      expect(tester.widget<Slider>(slider).value, 0.4);
      final range = find.byType(RangeSlider);
      await _show(tester, range);
      await tester.drag(range, const Offset(100, 0));
      await tester.pump();
      expect(
        tester.widget<RangeSlider>(range).values,
        const RangeValues(20, 80),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
